// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleFlag – on-chain boolean flag per user
/// @author acaiafa.base.eth
contract SimpleFlag {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    // -------------------------------------------------------------------------
    // FLAG STATE
    // -------------------------------------------------------------------------

    mapping(address => bool) public flag;

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event FlagSet(
        address indexed user,
        bool value,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );

    event FlagToggled(
        address indexed user,
        bool newValue,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );    
}
