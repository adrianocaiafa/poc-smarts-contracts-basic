// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleGM
/// @notice Registro simples de "GM" on-chain com contagem de usuários, gms e streaks
contract SimpleGM {
    // ====== Métricas genéricas de interação ======

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    // ====== Dados específicos de GM ======

    // Quantos GMs esse address já deu no total
    mapping(address => uint256) public gmCount;

    // "Dia" (em número inteiro) do último GM dado por esse address
    mapping(address => uint256) public lastGMDay;

    // Streak atual de dias seguidos dando GM
    mapping(address => uint256) public currentStreak;

    // Melhor streak já atingida
    mapping(address => uint256) public bestStreak;

    error AlreadyGmToday();

    event GoodMorning(
        address indexed user,
        uint256 day,
        uint256 gmCount,
        uint256 currentStreak,
        uint256 bestStreak
    );

    /// @notice Dá um "GM" on-chain (no máximo 1 vez por dia por address)
    function gm() external {
        uint256 today = block.timestamp / 1 days;

        // Já deu GM hoje?
        if (lastGMDay[msg.sender] == today) {
            revert AlreadyGmToday();
        }

        // Registro genérico de interação
        if (!hasInteracted[msg.sender]) {
            hasInteracted[msg.sender] = true;
            totalUniqueUsers += 1;
        }
        interactionsCount[msg.sender] += 1;

        // Atualiza contagem de GMs
        gmCount[msg.sender] += 1;

        // Streak de dias seguidos
        if (lastGMDay[msg.sender] + 1 == today) {
            // manteve streak
            currentStreak[msg.sender] += 1;
        } else {
            // resetou streak
            currentStreak[msg.sender] = 1;
        }

        // Atualiza best streak
        if (currentStreak[msg.sender] > bestStreak[msg.sender]) {
            bestStreak[msg.sender] = currentStreak[msg.sender];
        }

        // Atualiza o "dia" do último GM
        lastGMDay[msg.sender] = today;

        emit GoodMorning(
            msg.sender,
            today,
            gmCount[msg.sender],
            currentStreak[msg.sender],
            bestStreak[msg.sender]
        );
    }

    // @notice Retorna um resumo dos seus dados de GM
    function myGMData()
        external
        view
        returns (
            uint256 _gmCount,
            uint256 _currentStreak,
            uint256 _bestStreak,
            uint256 _lastGMTimestamp
        )
    {
        _gmCount = gmCount[msg.sender];
        _currentStreak = currentStreak[msg.sender];
        _bestStreak = bestStreak[msg.sender];
        _lastGMTimestamp = lastGMDay[msg.sender] * 1 days;
    }
}
