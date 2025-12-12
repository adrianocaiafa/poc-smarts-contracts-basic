// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimplePing
/// @notice Minimal contract to record pings per user
contract SimplePing {
mapping(address => uint256) public pingCount;
    mapping(address => uint256) public lastPingAt;

    uint256 public totalPings;

    event Ping(address indexed user, uint256 count, uint256 timestamp);

    function ping() external {
        pingCount[msg.sender] += 1;
        lastPingAt[msg.sender] = block.timestamp;
        totalPings += 1;

        emit Ping(msg.sender, pingCount[msg.sender], block.timestamp);
    }
}
