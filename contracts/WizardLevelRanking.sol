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

    // ======== EVENTS ========

    event WizardRegistered(address indexed wizard);
    event XPGained(address indexed wizard, uint256 amount, uint256 newXP, uint256 newLevel);
    event ManaGained(address indexed wizard, uint256 amount, uint256 newMana);
    event LevelUp(address indexed wizard, uint256 newLevel);
    event SpellCast(
        address indexed from,
        address indexed to,
        uint256 manaSpent,
        uint256 xpGained,
        uint256 newLevel
    );

    // ======== CORE INTERNAL REGISTRATION ========

    function _registerWizard(address _wizard) internal {
        if (!hasInteracted[_wizard]) {
            hasInteracted[_wizard] = true;
            totalUniqueWizards += 1;
            wizards.push(_wizard);
            emit WizardRegistered(_wizard);
        }
        interactionsCount[_wizard] += 1;
    }

    // ======== WRITE FUNCTIONS ========

    /// @notice Gain raw XP (e.g. off-chain quest, quest completion, etc.)
    function gainXP(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        _registerWizard(msg.sender);

        xp[msg.sender] += amount;

        // compute new level
        uint256 newLevel = xp[msg.sender] / XP_PER_LEVEL;

        if (newLevel > level[msg.sender]) {
            level[msg.sender] = newLevel;
            // bonus mana per level up
            uint256 manaBonus = (newLevel * MANA_PER_LEVEL);
            mana[msg.sender] += manaBonus;
            emit LevelUp(msg.sender, newLevel);
            emit ManaGained(msg.sender, manaBonus, mana[msg.sender]);
        }

        emit XPGained(msg.sender, amount, xp[msg.sender], level[msg.sender]);
    }

     /// @notice Meditate to gain mana (pure flavor, but on-chain)
    function meditate(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        _registerWizard(msg.sender);

        mana[msg.sender] += amount;
        emit ManaGained(msg.sender, amount, mana[msg.sender]);
    }

    /// @notice Cast a spell on another wizard: spend mana, gain XP
    /// @dev Very simple: more mana spent = more XP gained
    function castSpell(address target, uint256 manaToSpend) external {
        require(target != address(0), "Invalid target");
        require(target != msg.sender, "Cannot cast on yourself");
        require(manaToSpend > 0, "Mana must be > 0");
        require(mana[msg.sender] >= manaToSpend, "Not enough mana");

        _registerWizard(msg.sender);
        _registerWizard(target);

        // spend mana
        mana[msg.sender] -= manaToSpend;

        // gain XP proportional to mana spent
        uint256 gainedXP = manaToSpend; // 1:1 for simplicity
        xp[msg.sender] += gainedXP;
        spellsCast[msg.sender] += 1;

        // level calc
        uint256 newLevel = xp[msg.sender] / XP_PER_LEVEL;
        if (newLevel > level[msg.sender]) {
            level[msg.sender] = newLevel;
            uint256 manaBonus = (newLevel * MANA_PER_LEVEL);
            mana[msg.sender] += manaBonus;
            emit LevelUp(msg.sender, newLevel);
            emit ManaGained(msg.sender, manaBonus, mana[msg.sender]);
        }

        emit SpellCast(msg.sender, target, manaToSpend, gainedXP, level[msg.sender]);
    }
}