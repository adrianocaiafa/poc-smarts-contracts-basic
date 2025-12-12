// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleTimeTracker – on-chain check-ins with timestamps per user
/// @author acaiafa.base.eth
contract SimpleTimeTracker {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    // -------------------------------------------------------------------------
    // CHECK-IN STATE
    // -------------------------------------------------------------------------

    mapping(address => uint256) public checkInCount;
    mapping(address => uint256) public lastCheckInAt;

    uint256 public totalCheckIns;

}
