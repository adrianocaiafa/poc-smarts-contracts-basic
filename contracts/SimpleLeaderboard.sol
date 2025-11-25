// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleLeaderboard
/// @notice Sistema simples de leaderboard + pontos + contagem de usuários únicos
contract SimpleLeaderboard {

    // ======== METRICAS PADRÃO ========

    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    // ======== PONTOS E LISTA DE PARTICIPANTES ========

    mapping(address => uint256) public points;
    address[] internal participants; // lista de endereços que já interagiram

    event PointsGained(address indexed user, uint256 amount, uint256 newTotal);
    event DuelResult(address indexed winner, address indexed loser, uint256 amountWon);


    // ======== FUNÇÃO WRITE: GANHAR PONTOS ========

    function gainPoints(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        _registerUser(msg.sender);

        points[msg.sender] += amount;

        emit PointsGained(msg.sender, amount, points[msg.sender]);
    }


    // ======== FUNÇÃO WRITE 2: DUELO SIMPLES ENTRE USUARIOS ========
    /// @notice Quem tiver mais pontos ganha um bônus simples
    function duel(address opponent, uint256 amount) external {
        require(opponent != address(0), "Invalid user");
        require(opponent != msg.sender, "Can't duel yourself");
        require(points[msg.sender] >= amount, "Not enough points");
        require(points[opponent] >= amount, "Opponent lacks points");

        _registerUser(msg.sender);

        if (points[msg.sender] == points[opponent]) {
            // empate = ninguém ganha
            return;
        }

        address winner;
        address loser;

        if (points[msg.sender] > points[opponent]) {
            winner = msg.sender;
            loser = opponent;
        } else {
            winner = opponent;
            loser = msg.sender;
        }

        // vencedor ganha +amount, perdedor perde -amount
        points[winner] += amount;
        points[loser] -= amount;

        emit DuelResult(winner, loser, amount);
    }


    // ======== FUNÇÃO READ: RETORNAR O LEADERBOARD ORDENADO ========
    /// @notice Retorna um leaderboard ordenado por pontos (descendente)
    function getLeaderboard()
        external
        view
        returns (address[] memory users, uint256[] memory scores)
    {
        uint256 len = participants.length;

        users = new address[](len);
        scores = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            users[i] = participants[i];
            scores[i] = points[participants[i]];
        }

        // ======== Bubble sort simples PARA LEITURA (não grava nada em storage) ========
        for (uint256 i = 0; i < len; i++) {
            for (uint256 j = 0; j < len - 1; j++) {
                if (scores[j] < scores[j + 1]) {
                    (scores[j], scores[j + 1]) = (scores[j + 1], scores[j]);
                    (users[j], users[j + 1]) = (users[j + 1], users[j]);
                }
            }
        }
    }


    // ======== UTILS ========

    function myPoints() external view returns (uint256) {
        return points[msg.sender];
    }

    function myInteractions() external view returns (uint256) {
        return interactionsCount[msg.sender];
    }

    function _registerUser(address user) internal {
        if (!hasInteracted[user]) {
            hasInteracted[user] = true;
            totalUniqueUsers += 1;
            participants.push(user);
        }
        interactionsCount[user] += 1;
    }
}
