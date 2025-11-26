// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title WizardLevelRanking
/// @notice Simple on-chain wizard ranking with XP, levels, mana and spell casting
contract WizardLevelRanking {
    // ======== GENERIC INTERACTION METRICS ========

    uint256 public totalUniqueWizards;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;
}