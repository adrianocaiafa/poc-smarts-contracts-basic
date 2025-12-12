// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleVoting
/// @notice Yes/No voting on a single proposal
contract SimpleVoting {
    string public proposal;
    uint256 public yesVotes;
    uint256 public noVotes;

    mapping(address => bool) public hasVoted;

    event Voted(address indexed voter, bool support);
}
