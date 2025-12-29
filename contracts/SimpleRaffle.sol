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
}
