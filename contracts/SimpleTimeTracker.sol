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

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event CheckedIn(
        address indexed user,
        uint256 userCheckIns,
        uint256 timestamp,
        uint256 userInteractions,
        uint256 totalUniqueUsers,
        uint256 totalCheckIns
    );

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    /// @notice Record a check-in for the caller
    function checkIn() external {
        _registerInteraction();

        checkInCount[msg.sender] += 1;
        lastCheckInAt[msg.sender] = block.timestamp;
        totalCheckIns += 1;

        emit CheckedIn(
            msg.sender,
            checkInCount[msg.sender],
            block.timestamp,
            interactionsCount[msg.sender],
            totalUniqueUsers,
            totalCheckIns
        );
    }
}
