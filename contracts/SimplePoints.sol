// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimplePoints
/// @notice Sistema simples de pontos on-chain + contagem de usuários únicos
contract SimplePoints {

    uint256 public totalUniqueUsers;

    mapping(address => bool) public hasInteracted;

    mapping(address => uint256) public interactionsCount;

    mapping(address => uint256) public points;

    event PointsGained(address indexed user, uint256 amount, uint256 newBalance);
    event PointsGiven(address indexed from, address indexed to, uint256 amount);


    // ====== FUNÇÃO 1: GANHAR PONTOS ======

    /// @notice Ganhe pontos simplesmente interagindo
    function gainPoints(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        // Contar usuario unico uma vez
        if (!hasInteracted[msg.sender]) {
            hasInteracted[msg.sender] = true;
            totalUniqueUsers += 1;
        }

        interactionsCount[msg.sender] += 1;

        points[msg.sender] += amount;

        emit PointsGained(msg.sender, amount, points[msg.sender]);
    }


    // ====== FUNÇÃO 2: DAR PONTOS PARA OUTRA WALLET ======

    /// @notice Envia pontos para outra wallet
    function givePoints(address to, uint256 amount) external {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be > 0");
        require(points[msg.sender] >= amount, "Not enough points");

        // Contagem de interacoes / usuarios unicos
        if (!hasInteracted[msg.sender]) {
            hasInteracted[msg.sender] = true;
            totalUniqueUsers += 1;
        }

        interactionsCount[msg.sender] += 1;

        // Transfere pontos
        points[msg.sender] -= amount;
        points[to] += amount;

        emit PointsGiven(msg.sender, to, amount);
    }


    // ====== READ FUNCTIONS ======

    function myPoints() external view returns (uint256) {
        return points[msg.sender];
    }

    function myInteractions() external view returns (uint256) {
        return interactionsCount[msg.sender];
    }
}
