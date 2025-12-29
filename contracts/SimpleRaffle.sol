// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * SimpleRaffle (MVP) - Base (EVM)
 * - Users buy tickets paying ETH (native)
 * - Owner closes round and picks a weighted winner (by tickets)
 * - Winner claims the pot (pull payment)
 *
 * NOTE: RNG is NOT secure (MVP). Use Chainlink VRF for production.
 */
contract SimpleRaffle {
    // -----------------------
    // Errors (cheaper than require strings)
    // -----------------------
    error RaffleClosed();
    error AlreadyClosed();
    error NoParticipants();
    error InvalidTicketCount();
    error InvalidValue();
    error PrizeNotAvailable();
    error TransferFailed();
    error RoundStillOpen();

    // -----------------------
    // Config (MVP)
    // -----------------------
    uint256 public constant MAX_TICKETS_PER_TX = 100;

    address public owner;
    uint256 public ticketPriceWei;

    uint256 public currentRound = 1;

    // Round state
    mapping(uint256 => bool) public isOpen;                 // round => open?
    mapping(uint256 => uint256) public totalTickets;        // round => total tickets
    mapping(uint256 => uint256) public pot;                 // round => ETH collected
    mapping(uint256 => address) public winner;              // round => winner address

    // Participant storage
    mapping(uint256 => address[]) private participants;                 // round => participants list
    mapping(uint256 => mapping(address => bool)) private isParticipant; // round => already in list?
    mapping(uint256 => mapping(address => uint256)) public ticketsOf;   // round => participant => ticket count

    // Pull payment credits (winner claims)
    mapping(address => uint256) public claimable;

    // -----------------------
    // Events
    // -----------------------
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event TicketPriceChanged(uint256 oldPriceWei, uint256 newPriceWei);

    event TicketsBought(
        uint256 indexed round,
        address indexed buyer,
        uint256 ticketCount,
        uint256 paidWei
    );

    event RoundClosed(
        uint256 indexed round,
        address indexed winner,
        uint256 winnerTickets,
        uint256 totalTickets,
        uint256 potWei
    );

    event NewRoundStarted(uint256 indexed newRound);
    event PrizeClaimed(address indexed winner, uint256 amountWei);

    // -----------------------
    // Modifiers
    // -----------------------
    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    // -----------------------
    // Constructor
    // -----------------------
    constructor(uint256 _ticketPriceWei) {
        owner = msg.sender;
        ticketPriceWei = _ticketPriceWei;

        isOpen[currentRound] = true;
    }

    // -----------------------
    // Admin / Config
    // -----------------------
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ZERO_ADDR");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    /// @notice You can set a very low ticket price (in wei).
    /// @dev Keep in mind gas will likely dwarf the ticket price.
    function setTicketPriceWei(uint256 newPriceWei) external onlyOwner {
        emit TicketPriceChanged(ticketPriceWei, newPriceWei);
        ticketPriceWei = newPriceWei;
    }

    // -----------------------
    // Core: buy tickets
    // -----------------------
    function buyTickets(uint256 ticketCount) external payable {
        uint256 round = currentRound;

        if (!isOpen[round]) revert RaffleClosed();
        if (ticketCount == 0 || ticketCount > MAX_TICKETS_PER_TX) revert InvalidTicketCount();

        uint256 expected = ticketPriceWei * ticketCount;
        if (msg.value != expected) revert InvalidValue();

        // Add to participant list if first time in round
        if (!isParticipant[round][msg.sender]) {
            isParticipant[round][msg.sender] = true;
            participants[round].push(msg.sender);
        }

        ticketsOf[round][msg.sender] += ticketCount;
        totalTickets[round] += ticketCount;
        pot[round] += msg.value;

        emit TicketsBought(round, msg.sender, ticketCount, msg.value);
    }

    // -----------------------
    // Admin: close and pick winner (weighted)
    // -----------------------
    function closeAndPickWinner() external onlyOwner {
        uint256 round = currentRound;

        if (!isOpen[round]) revert AlreadyClosed();
        uint256 sold = totalTickets[round];
        if (sold == 0) revert NoParticipants();

        isOpen[round] = false;

        // Pseudo-random seed (MVP, not secure)
        uint256 rnd = uint256(
            keccak256(
                abi.encodePacked(
                    block.prevrandao, // EVM randomness source (still manipulable)
                    block.timestamp,
                    block.number,
                    sold,
                    pot[round],
                    address(this)
                )
            )
        );

        // Winning ticket number in [1..sold]
        uint256 winningTicket = (rnd % sold) + 1;

        // Walk participants cumulatively to find who owns that ticket
        address win = _findWinnerByTicket(round, winningTicket);

        winner[round] = win;

        uint256 prize = pot[round];
        pot[round] = 0;

        // Pull payment: credit winner
        claimable[win] += prize;

        emit RoundClosed(
            round,
            win,
            ticketsOf[round][win],
            sold,
            prize
        );
    }

    function _findWinnerByTicket(uint256 round, uint256 winningTicket) internal view returns (address) {
        address[] memory list = participants[round];
        uint256 cumulative = 0;

        // O(n) scan - fine for MVP
        for (uint256 i = 0; i < list.length; i++) {
            address p = list[i];
            cumulative += ticketsOf[round][p];
            if (winningTicket <= cumulative) {
                return p;
            }
        }

        // Should never happen if totals are consistent
        return list[list.length - 1];
    }
}
