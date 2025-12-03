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
}
