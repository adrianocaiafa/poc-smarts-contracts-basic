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

    // tasksByUser[user] = array of tasks
    mapping(address => Task[]) private tasksByUser;

    event TaskAdded(address indexed user, uint256 indexed id, string text);

    function addTask(string calldata _text) external {
        Task[] storage list = tasksByUser[msg.sender];
        uint256 id = list.length;

        list.push(Task({id: id, text: _text, done: false, deleted: false}));

        emit TaskAdded(msg.sender, id, _text);
    }    

}
