// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleNotes {
    struct Note {
        uint256 id;
        address owner;
        string text;
        uint256 createdAt;
        uint256 updatedAt;
        bool deleted;
    }

    Note[] public notes; // notes[0] pode ficar "vazio" se quiser começar de 1, mas vamos usar direto
    mapping(address => uint256[]) public noteIdsByOwner;

    function addNote(string calldata _text) external {
        uint256 id = notes.length;

        notes.push(
            Note({
                id: id,
                owner: msg.sender,
                text: _text,
                createdAt: block.timestamp,
                updatedAt: block.timestamp,
                deleted: false
            })
        );

        noteIdsByOwner[msg.sender].push(id);
    }

    function getNote(uint256 id) external view returns (Note memory) {
        return notes[id];
    }

    function getMyNotes() external view returns (Note[] memory) {
        uint256[] memory ids = noteIdsByOwner[msg.sender];
        Note[] memory result = new Note[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            result[i] = notes[ids[i]];
        }

        return result;
    }
}
