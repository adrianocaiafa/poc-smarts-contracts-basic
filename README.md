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
