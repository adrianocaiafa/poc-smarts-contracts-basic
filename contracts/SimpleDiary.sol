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

    event EntrySet(address indexed user, string text, uint256 updatedAt);
    event EntryCleared(address indexed user);

    function setEntry(string calldata _text) external {
        entries[msg.sender] = Entry({text: _text, updatedAt: block.timestamp});
        emit EntrySet(msg.sender, _text, block.timestamp);
    }

    function clearEntry() external {
        delete entries[msg.sender];
        emit EntryCleared(msg.sender);
    }
}
