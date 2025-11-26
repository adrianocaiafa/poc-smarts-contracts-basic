// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title WizardLevelRanking
/// @notice Simple on-chain wizard ranking with XP, levels, mana and spell casting
contract WizardLevelRanking {
    // ======== GENERIC INTERACTION METRICS ========

    uint256 public totalUniqueWizards;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    // ======== WIZARD STATS ========

    mapping(address => uint256) public xp;          // total XP
    mapping(address => uint256) public level;       // current level
    mapping(address => uint256) public mana;        // current mana
    mapping(address => uint256) public spellsCast;  // total spells cast

    address[] internal wizards; // list of all wizards that ever interacted

    uint256 public constant XP_PER_LEVEL   = 100;  // 100 XP per level
    uint256 public constant MANA_PER_LEVEL = 10;   // bonus mana per level up
    uint256 public constant BASE_SPELL_COST = 5;   // default mana cost for spells
}