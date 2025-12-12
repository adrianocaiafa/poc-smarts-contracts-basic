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
}
