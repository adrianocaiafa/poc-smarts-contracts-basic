// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleStatus – on-chain status message per user
/// @author acaiafa.base.eth
contract SimpleStatus {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount; 

    // -------------------------------------------------------------------------
    // STATUS STATE
    // -------------------------------------------------------------------------

    mapping(address => string) public status;    

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event StatusSet(
        address indexed user,
        string newStatus,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );    

    event StatusCleared(
        address indexed user,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );   

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    /// @notice Set or update your on-chain status message
    function setStatus(string calldata _status) external {
        _registerInteraction();

        status[msg.sender] = _status;

        emit StatusSet(
            msg.sender,
            _status,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );
    }

    /// @notice Clear your current status
    function clearStatus() external {
        _registerInteraction();

        delete status[msg.sender];

        emit StatusCleared(
            msg.sender,
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
}
