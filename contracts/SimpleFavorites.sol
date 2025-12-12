// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleFavorites – on-chain favorite number per user
/// @author acaiafa.base.eth
contract SimpleFavorites {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;    

    // -------------------------------------------------------------------------
    // FAVORITE STATE
    // -------------------------------------------------------------------------

    mapping(address => uint256) public favoriteNumber;
    mapping(address => bool) public hasFavorite;  

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event FavoriteSet(
        address indexed user,
        uint256 number,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );

    event FavoriteCleared(
        address indexed user,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    /// @notice Set or update your favorite number
    function setFavorite(uint256 _number) external {
        _registerInteraction();

        favoriteNumber[msg.sender] = _number;
        hasFavorite[msg.sender] = true;

        emit FavoriteSet(
            msg.sender,
            _number,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );
    }

    /// @notice Clear your favorite number
    function clearFavorite() external {
        _registerInteraction();

        delete favoriteNumber[msg.sender];
        hasFavorite[msg.sender] = false;

        emit FavoriteCleared(
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
