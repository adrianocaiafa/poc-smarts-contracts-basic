// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleCounter
/// @notice Minimal global counter contract
contract SimpleCounter {
    uint256 public count;

    event Increment(address indexed caller, uint256 newValue);
    event Decrement(address indexed caller, uint256 newValue);
    event Reset(address indexed caller);

    function increment() external {
        count += 1;
        emit Increment(msg.sender, count);
    }

    function decrement() external {
        require(count > 0, "Counter is zero");
        count -= 1;
        emit Decrement(msg.sender, count);
    }

    function reset() external {
        count = 0;
        emit Reset(msg.sender);
    }
}
