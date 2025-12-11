// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleReactions
/// @notice Like/dislike system for a single shared "item"
contract SimpleReactions {
    // -1 = dislike, 0 = none, 1 = like
    mapping(address => int8) public reactions;
    uint256 public likes;
    uint256 public dislikes;

    event Reacted(address indexed user, int8 reaction);

    function like() external {
        _setReaction(1);
    }

    function dislike() external {
        _setReaction(-1);
    }

    function clearReaction() external {
        _setReaction(0);
    }

    function _setReaction(int8 newReaction) internal {
        require(newReaction >= -1 && newReaction <= 1, "Invalid reaction");

        int8 old = reactions[msg.sender];

        if (old == newReaction) {
            // nothing to change
            return;
        }

        // Remove old reaction from counters
        if (old == 1) {
            likes -= 1;
        } else if (old == -1) {
            dislikes -= 1;
        }

        // Apply new
        reactions[msg.sender] = newReaction;

        if (newReaction == 1) {
            likes += 1;
        } else if (newReaction == -1) {
            dislikes += 1;
        }

        emit Reacted(msg.sender, newReaction);
    }
}
