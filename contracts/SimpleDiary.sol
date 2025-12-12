// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleDiary
/// @notice Each user can store a single diary entry on-chain
contract SimpleDiary {
    struct Entry {
        string text;
        uint256 updatedAt;
    }

    mapping(address => Entry) private entries;

}
