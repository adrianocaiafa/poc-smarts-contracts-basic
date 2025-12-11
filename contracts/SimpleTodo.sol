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
    event TaskToggled(address indexed user, uint256 indexed id, bool done);

    function addTask(string calldata _text) external {
        Task[] storage list = tasksByUser[msg.sender];
        uint256 id = list.length;

        list.push(Task({id: id, text: _text, done: false, deleted: false}));

        emit TaskAdded(msg.sender, id, _text);
    }    

    function toggleDone(uint256 _id) external {
        Task storage t = _getTask(msg.sender, _id);
        require(!t.deleted, "Task deleted");
        t.done = !t.done;
        emit TaskToggled(msg.sender, _id, t.done);
    }
}
