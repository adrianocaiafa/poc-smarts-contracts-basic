// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleBookmarks – on-chain single bookmark per user (URL or reference)
/// @author acaiafa.base.eth
contract SimpleBookmarks {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;    

    // -------------------------------------------------------------------------
    // BOOKMARK STATE
    // -------------------------------------------------------------------------

    mapping(address => string) public bookmark;   

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event BookmarkSaved(
        address indexed user,
        string url,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );     

    event BookmarkCleared(
        address indexed user,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );    

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    /// @notice Save or update your single on-chain bookmark (URL, handle, etc.)
    function saveBookmark(string calldata _url) external {
        _registerInteraction();

        bookmark[msg.sender] = _url;

        emit BookmarkSaved(
            msg.sender,
            _url,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );
    }  

    /// @notice Clear your current bookmark
    function clearBookmark() external {
        _registerInteraction();

        delete bookmark[msg.sender];

        emit BookmarkCleared(
            msg.sender,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );
    }      
}
