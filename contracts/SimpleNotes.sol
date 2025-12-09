// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleNotes - basic on-chain note storage
/// @notice First minimal version with a single global note
contract SimpleNotes {
    string public note;

    function setNote(string calldata _note) external {
        note = _note;
    }
}
