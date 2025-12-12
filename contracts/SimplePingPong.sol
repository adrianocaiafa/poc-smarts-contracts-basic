// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimplePingPong – on-chain ping/pong interactions with counters
/// @author acaiafa.base.eth
contract SimplePingPong {
    // -------------------------------------------------------------------------
    // GENERIC INTERACTION METRICS
    // -------------------------------------------------------------------------

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    // -------------------------------------------------------------------------
    // PING/PONG STATE
    // -------------------------------------------------------------------------

    mapping(address => uint256) public pingCount;
    mapping(address => uint256) public pongCount;
    mapping(address => uint256) public lastActionAt;

    uint256 public totalPings;
    uint256 public totalPongs;

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event Pinged(
        address indexed user,
        uint256 userPings,
        uint256 totalPings,
        uint256 timestamp,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );

    event Ponged(
        address indexed user,
        uint256 userPongs,
        uint256 totalPongs,
        uint256 timestamp,
        uint256 userInteractions,
        uint256 totalUniqueUsers
    );

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    /// @notice Records a ping and returns "PONG"
    function ping() external returns (string memory) {
        _registerInteraction();

        pingCount[msg.sender] += 1;
        totalPings += 1;
        lastActionAt[msg.sender] = block.timestamp;

        emit Pinged(
            msg.sender,
            pingCount[msg.sender],
            totalPings,
            block.timestamp,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );

        return "PONG";
    }

    /// @notice Records a pong and returns "PING"
    function pong() external returns (string memory) {
        _registerInteraction();

        pongCount[msg.sender] += 1;
        totalPongs += 1;
        lastActionAt[msg.sender] = block.timestamp;

        emit Ponged(
            msg.sender,
            pongCount[msg.sender],
            totalPongs,
            block.timestamp,
            interactionsCount[msg.sender],
            totalUniqueUsers
        );

        return "PING";
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

    /// @notice Returns your ping/pong counts and your last action timestamp
    function myPingPong()
        external
        view
        returns (uint256 pings, uint256 pongs, uint256 lastAt)
    {
        return (pingCount[msg.sender], pongCount[msg.sender], lastActionAt[msg.sender]);
    }
}
