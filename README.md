# SimpleNotes

`SimpleNotes` is a minimal on-chain notes contract written in Solidity.  
It allows users to create, like, pin, and soft-delete notes, while keeping a simple
and gas-conscious data model.

The goal of this project is to serve as a clean, educational PoC (proof of concept)
for basic CRUD-style patterns on EVM smart contracts, and to be a good sandbox for
iterative improvements (archiving, visibility, gas optimizations, tests, etc.).

---

## Features

- Create notes associated with the caller (`msg.sender`)
- Soft delete notes (flag as deleted instead of removing from storage)
- Like notes once per address
- Pin a single note per user
- List:
  - A single note by id
  - All notes created by the caller
  - All notes created by a specific owner
- Pause/unpause mutating operations (owner-only)

---

## Contract Overview

```solidity
struct Note {
    uint256 id;
    address owner;
    string text;
    uint256 createdAt;
    uint256 updatedAt;
    bool deleted;
}

Key mappings:

noteIdsByOwner[address] -> uint256[]

likes[noteId] -> uint256

hasLiked[noteId][address] -> bool

pinnedNoteId[address] -> noteId

Admin:

owner – contract owner

paused – simple switch to pause mutating functions

Main Functions
Write

addNote(string _text)
Creates a new note owned by msg.sender.

deleteNote(uint256 _id)
Marks a note as deleted (only by its owner).

likeNote(uint256 _id)
Registers a like from msg.sender for the given note (once per address).

pinMyNote(uint256 _id)
Pins a note for the caller.

setPaused(bool _paused)
Owner-only; pauses or unpauses mutating operations.

Read

getNote(uint256 _id) -> Note

getMyNotes() -> Note[]

getNotesByOwner(address _owner) -> Note[]

totalNotes() -> uint256

myNotesCount() -> uint256

Tooling & Setup (suggested)

While the contract was initially developed with Remix, you can also use Hardhat
for local testing and scripting:

npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat init


Place SimpleNotes.sol under contracts/, then write tests under test/.