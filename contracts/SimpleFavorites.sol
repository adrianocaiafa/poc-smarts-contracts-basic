// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleFavorites – on-chain favorite number per user
/// @author acaiafa.base.eth
contract SimpleFavorites {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;    
}
