// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleGM
/// @notice Registro simples de "GM" on-chain com contagem de usuários, gms e streaks
contract SimpleGM {
    // ====== Métricas genéricas de interação ======

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;
}
