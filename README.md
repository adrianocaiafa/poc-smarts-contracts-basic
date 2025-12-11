# SimpleNotes

`SimpleNotes` is a minimal on-chain notes contract written in Solidity.  
It allows users to create, like, pin, and soft-delete notes while keeping a simple
and gas-efficient data model.

This project serves as a clean, educational PoC (proof of concept)
for basic CRUD-style patterns on EVM smart contracts and as a sandbox for gradual
feature improvements (archiving, visibility, gas optimizations, tests, etc.).

---

## ✨ Features

- Create notes associated with the caller (`msg.sender`)
- Soft delete notes (mark as deleted instead of removing from storage)
- Like notes once per address
- Pin a single note per user
- List:
  - A single note by ID  
  - All notes created by the caller  
  - All notes created by a specific owner
- Pause/unpause mutating operations (owner-only)
- Notes can now be archived/unarchived
- Archived notes remain readable but filtered out by helper methods
- Active notes = not deleted and not archived
- Support for public and private notes with visibility toggling

---

## 📜 Contract Overview

### Struct

```solidity
struct Note {
    uint64 id;
    uint64 createdAt;
    uint64 updatedAt;
    bool deleted;
    bool archived;
    bool isPublic;
    address owner;
    string text;
}
```

### Key mappings

```
noteIdsByOwner[address]      -> uint256[]
likes[noteId]                -> uint256
hasLiked[noteId][address]    -> bool
pinnedNoteId[address]        -> noteId
```

### Admin fields

```
owner   – contract owner
paused  – simple switch to pause mutating functions
```

---

## 🛠 Main Functions

### Write functions

#### `addNote(string _text)`
Creates a new note owned by `msg.sender`.

#### `deleteNote(uint256 _id)`
Marks a note as deleted (only removable by its owner).

#### `archiveNote(uint256 _id)`
Archives a note without deleting it (owner-only).

#### `unarchiveNote(uint256 _id)`
Restores a previously archived note (owner-only).

#### `likeNote(uint256 _id)`
Registers a like from `msg.sender`. One like per address.

#### `pinMyNote(uint256 _id)`
Pins a note so the caller can mark a preferred/important note.

#### `setPaused(bool _paused)`  
Owner-only; pauses or unpauses mutating operations.

#### `setVisibility(uint256 _id, bool _isPublic)`  
Sets a note as public or private (owner-only).

---

### Read functions

#### `getNote(uint256 _id) -> Note`
Retrieves full note data.

#### `getMyNotes() -> Note[]`
Returns all notes created by the caller.

#### `getNotesByOwner(address _owner) -> Note[]`
Returns all notes created by a specific owner.

#### `getActiveNotesByOwner(address _owner) -> Note[]`
Returns only notes that are not deleted and not archived.

#### `totalNotes() -> uint256`
Total count of notes stored.

#### `myNotesCount() -> uint256`
How many notes the caller has created.

#### `getPublicNotesByOwner(address _owner) -> Note[]`
Returns all public, non-deleted, non-archived notes from the given owner.

---

## 🔧 Tooling & Setup (Hardhat Recommended)

Although the contract can be developed fully in Remix, using **Hardhat** provides
a better workflow for testing, compiling, and scripting.

### Install Hardhat

```bash
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat init
```

Move your contract into:

```
contracts/SimpleNotes.sol
```

Then create test files under:

```
test/SimpleNotes.js (or .ts)
```

---

## 🚀 Future Improvements

These features are planned or suggested as next steps:

- Optional **front-end** to interact with the contract on any EVM chain

This repository is intentionally kept simple to encourage small, incremental
commits and experimentation.
