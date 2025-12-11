// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleRegistry
/// @notice Public name registry by address
contract SimpleRegistry {
    mapping(address => string) public names;

    event NameSet(address indexed user, string name);
    event NameCleared(address indexed user);

    function setName(string calldata _name) external {
        names[msg.sender] = _name;
        emit NameSet(msg.sender, _name);
    }

    function clearName() external {
        delete names[msg.sender];
        emit NameCleared(msg.sender);
    }

    function getName(address _user) external view returns (string memory) {
        return names[_user];
    }
}
