// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimplePing
/// @notice Minimal contract to record pings per user
contract SimplePing {
mapping(address => uint256) public pingCount;
    mapping(address => uint256) public lastPingAt;

    uint256 public totalPings;    
}
