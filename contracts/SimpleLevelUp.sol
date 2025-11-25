// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SimpleLevelUp – XP + Níveis + Leaderboard automático
/// @author acaiafa.base.eth
contract SimpleLevelUp {

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    mapping(address => uint256) public xp;
    mapping(address => uint256) public level;
    uint256 public constant XP_PER_LEVEL = 100;

    // Leaderboard dos 5 maiores níveis
    address[5] public topLevels;
    mapping(address => bool) public isInTop5;

    event XPGained(address indexed user, uint256 amount, uint256 newXP, uint256 newLevel);
    event LevelUp(address indexed user, uint256 newLevel);

    function gainXP(uint256 amount) external {
        require(amount > 0, "Amount > 0");

        if (!hasInteracted[msg.sender]) {
            hasInteracted[msg.sender] = true;
            totalUniqueUsers += 1;
        }
        interactionsCount[msg.sender] += 1;

        xp[msg.sender] += amount;
        uint256 newLevel = xp[msg.sender] / XP_PER_LEVEL;

        if (newLevel > level[msg.sender]) {
            level[msg.sender] = newLevel;
            _updateTop5(msg.sender);
            emit LevelUp(msg.sender, newLevel);
        }

        emit XPGained(msg.sender, amount, xp[msg.sender], level[msg.sender]);
    }

    function _updateTop5(address user) internal {
        if (isInTop5[user]) return;

        for (uint i = 0; i < 5; i++) {
            if (level[user] > level[topLevels[i]]) {
                for (uint j = 4; j > i; j--) {
                    topLevels[j] = topLevels[j-1];
                }
                topLevels[i] = user;
                isInTop5[user] = true;
                break;
            }
        }
    }

    // reads
    function myInteractions() external view returns (uint256) { return interactionsCount[msg.sender]; }
    function myXP() external view returns (uint256) { return xp[msg.sender]; }
    function myLevel() external view returns (uint256) { return level[msg.sender]; }
}