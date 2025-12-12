// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleStatus – on-chain status message per user
/// @author acaiafa.base.eth
contract SimpleStatus {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount; 

    // -------------------------------------------------------------------------
    // STATUS STATE
    // -------------------------------------------------------------------------

    mapping(address => string) public status;    

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event StatusSet(
        address indexed user,
        string newStatus,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );    
}
