// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleKudos – send simple on-chain kudos between addresses
/// @author acaiafa.base.eth
contract SimpleKudos {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;
    
    // -------------------------------------------------------------------------
    // KUDOS STATE
    // -------------------------------------------------------------------------

    // Total kudos a user has received
    mapping(address => uint256) public kudosReceived;

    // Total kudos a user has sent
    mapping(address => uint256) public kudosSent;

    uint256 public totalKudos;

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event KudosSent(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 senderInteractions,
        uint256 totalUniqueUsers,
        uint256 totalKudos
    );

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    /// @notice Send 1 kudos point to a given address
    function giveKudos(address _to) external {
        require(_to != address(0), "Invalid address");
        require(_to != msg.sender, "Cannot send to self");

        _registerInteraction();

        kudosSent[msg.sender] += 1;
        kudosReceived[_to] += 1;
        totalKudos += 1;

        emit KudosSent(
            msg.sender,
            _to,
            1,
            interactionsCount[msg.sender],
            totalUniqueUsers,
            totalKudos
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

    /// @notice How many kudos you have sent
    function myKudosSent() external view returns (uint256) {
        return kudosSent[msg.sender];
    }     
}
