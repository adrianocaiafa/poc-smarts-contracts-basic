// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleColorPicker – on-chain favorite color per user (RGB uint24)
/// @author acaiafa.base.eth
contract SimpleColorPicker {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount; 

    // -------------------------------------------------------------------------
    // COLOR STATE
    // -------------------------------------------------------------------------

    // Favorite color encoded as uint24 (0xRRGGBB)
    mapping(address => uint24) public favoriteColor;

    // Tracks if a user has explicitly set a color at least once
    mapping(address => bool) public hasColor;     

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event ColorSet(
        address indexed user,
        uint24 color,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );      

    event ColorCleared(
        address indexed user,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );    

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    /// @notice Set your favorite color as a uint24 RGB value (0xRRGGBB)
    function setColor(uint24 _color) external {
        _registerInteraction();

        favoriteColor[msg.sender] = _color;
        hasColor[msg.sender] = true;

        emit ColorSet(
            msg.sender,
            _color,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );
    }   

    /// @notice Clear your favorite color
    function clearColor() external {
        _registerInteraction();

        delete favoriteColor[msg.sender];
        hasColor[msg.sender] = false;

        emit ColorCleared(
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

    // -------------------------------------------------------------------------
    // READ HELPERS
    // -------------------------------------------------------------------------

    /// @notice How many times you have interacted with this contract
    function myInteractions() external view returns (uint256) {
        return interactionsCount[msg.sender];
    }

}
