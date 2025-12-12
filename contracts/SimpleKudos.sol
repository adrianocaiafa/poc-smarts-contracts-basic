// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleKudos – send simple on-chain kudos between addresses
/// @author acaiafa.base.eth
contract SimpleKudos {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;
    
    // -------------------------------------------------------------------------
    // KUDOS STATE
    // -------------------------------------------------------------------------

    // Total kudos a user has received
    mapping(address => uint256) public kudosReceived;

    // Total kudos a user has sent
    mapping(address => uint256) public kudosSent;

    uint256 public totalKudos;

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event KudosSent(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 senderInteractions,
        uint256 totalUniqueUsers,
        uint256 totalKudos
    );    
}
