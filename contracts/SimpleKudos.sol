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

}
