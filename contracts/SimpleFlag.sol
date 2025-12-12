// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleFlag – on-chain boolean flag per user
/// @author acaiafa.base.eth
contract SimpleFlag {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    // -------------------------------------------------------------------------
    // FLAG STATE
    // -------------------------------------------------------------------------

    mapping(address => bool) public flag;

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event FlagSet(
        address indexed user,
        bool value,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );

    event FlagToggled(
        address indexed user,
        bool newValue,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    /// @notice Explicitly set your flag value to true or false
    function setFlag(bool _value) external {
        _registerInteraction();

        flag[msg.sender] = _value;

        emit FlagSet(
            msg.sender,
            _value,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );
    }

    /// @notice Toggle your current flag value
    function toggleFlag() external {
        _registerInteraction();

        bool newValue = !flag[msg.sender];
        flag[msg.sender] = newValue;

        emit FlagToggled(
            msg.sender,
            newValue,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );
    } 

    // -------------------------------------------------------------------------
    // INTERNAL
    // -------------------------------------------------------------------------

    function _registerInteraction() internal {
        if (!hasInteracted[msg.sender]) {
            hasInteracted[msg.sender] = true;
            totalUniqueUsers += 1;
        }
        interactionsCount[msg.sender] += 1;
    }

    // -------------------------------------------------------------------------
    // READ HELPERS
    // -------------------------------------------------------------------------

    /// @notice How many times you have interacted with this contract
    function myInteractions() external view returns (uint256) {
        return interactionsCount[msg.sender];
    }

    /// @notice Returns your current flag value
    function myFlag() external view returns (bool) {
        return flag[msg.sender];
    } 
}
