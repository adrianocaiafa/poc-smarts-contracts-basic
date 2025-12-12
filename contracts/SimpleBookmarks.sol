// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleBookmarks – on-chain single bookmark per user (URL or reference)
/// @author acaiafa.base.eth
contract SimpleBookmarks {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;    
}
