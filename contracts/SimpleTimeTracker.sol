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

    // -------------------------------------------------------------------------
    // INTERNAL
    // -------------------------------------------------------------------------

    function _registerInteraction() internal {
        if (!hasInteracted[msg.sender]) {
            hasInteracted[msg.sender] = true;
            totalUniqueUsers += 1;
        }
        interactionsCount[msg.sender] += 1;
    }

    // -------------------------------------------------------------------------
    // READ HELPERS
    // -------------------------------------------------------------------------

    /// @notice How many times you have interacted with this contract
    function myInteractions() external view returns (uint256) {
        return interactionsCount[msg.sender];
    }

    /// @notice Returns your check-in count and last check-in timestamp
    function myCheckIn()
        external
        view
        returns (uint256 count, uint256 lastAt)
    {
        return (checkInCount[msg.sender], lastCheckInAt[msg.sender]);
    }
}
