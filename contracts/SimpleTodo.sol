// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleTodo
/// @notice Per-user todo list with simple tasks
contract SimpleTodo {
    struct Task {
        uint256 id;
        string text;
        bool done;
        bool deleted;
    }
}
