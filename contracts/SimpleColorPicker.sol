// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleColorPicker – on-chain favorite color per user (RGB uint24)
/// @author acaiafa.base.eth
contract SimpleColorPicker {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;    
}
