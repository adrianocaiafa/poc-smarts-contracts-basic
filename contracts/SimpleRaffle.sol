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


}
