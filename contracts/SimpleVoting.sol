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

    constructor(string memory _proposal) {
        proposal = _proposal;
    }

    /// @notice Vote on the proposal
    /// @param support true = yes, false = no
    function vote(bool support) external {
        require(!hasVoted[msg.sender], "Already voted");

        hasVoted[msg.sender] = true;

        if (support) {
            yesVotes += 1;
        } else {
            noVotes += 1;
        }

        emit Voted(msg.sender, support);
    }
}
