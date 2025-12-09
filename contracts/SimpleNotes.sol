// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleNotes {
    string[] public notes;

    function addNote(string calldata _note) external {
        notes.push(_note);
    }

    function getNote(uint256 index) external view returns (string memory) {
        return notes[index];
    }

    function notesCount() external view returns (uint256) {
        return notes.length;
    }
}
