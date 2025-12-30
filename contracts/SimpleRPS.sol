// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleRPS
/// @notice Pedra-Papel-Tesoura contra o "contrato" (random fraco, apenas para diversão)
contract SimpleRPS {
    enum Move {
        Rock,     // 0
        Paper,    // 1
        Scissors  // 2
    }

    enum Result {
        Lose, // user loses
        Draw, // tie
        Win   // user wins
    }

    // ====== Métricas genéricas de interação ======
    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    // ====== Métricas específicas do jogo ======
    mapping(address => uint256) public gamesPlayed;
    mapping(address => uint256) public wins;
    mapping(address => uint256) public draws;
    mapping(address => uint256) public losses;

    // Streak atual de vitórias (wins seguidas)
    mapping(address => uint256) public currentWinStreak;
    mapping(address => uint256) public bestWinStreak;

    error InvalidMove();

    event Played(
        address indexed user,
        Move userMove,
        Move contractMove,
        Result result,
        uint256 gamesPlayed,
        uint256 wins,
        uint256 currentWinStreak,
        uint256 bestWinStreak
    );

    /// @notice Joga RPS contra o contrato
    /// @param userMove 0=Rock, 1=Paper, 2=Scissors
    function play(uint8 userMove) external {
        if (userMove > 2) revert InvalidMove();

        // Registro genérico de interação
        if (!hasInteracted[msg.sender]) {
            hasInteracted[msg.sender] = true;
            totalUniqueUsers += 1;
        }
        interactionsCount[msg.sender] += 1;

        Move u = Move(userMove);
        Move c = _contractMove(msg.sender);

        Result r = _result(u, c);

        // Atualiza métricas
        gamesPlayed[msg.sender] += 1;

        if (r == Result.Win) {
            wins[msg.sender] += 1;

            currentWinStreak[msg.sender] += 1;
            if (currentWinStreak[msg.sender] > bestWinStreak[msg.sender]) {
                bestWinStreak[msg.sender] = currentWinStreak[msg.sender];
            }
        } else if (r == Result.Draw) {
            draws[msg.sender] += 1;

            // empate quebra streak de vitória (você pode mudar isso se quiser)
            currentWinStreak[msg.sender] = 0;
        } else {
            losses[msg.sender] += 1;
            currentWinStreak[msg.sender] = 0;
        }

        emit Played(
            msg.sender,
            u,
            c,
            r,
            gamesPlayed[msg.sender],
            wins[msg.sender],
            currentWinStreak[msg.sender],
            bestWinStreak[msg.sender]
        );
    }

    /// @notice Resumo dos seus stats
    function myStats()
        external
        view
        returns (
            uint256 _gamesPlayed,
            uint256 _wins,
            uint256 _draws,
            uint256 _losses,
            uint256 _currentWinStreak,
            uint256 _bestWinStreak
        )
    {
        _gamesPlayed = gamesPlayed[msg.sender];
        _wins = wins[msg.sender];
        _draws = draws[msg.sender];
        _losses = losses[msg.sender];
        _currentWinStreak = currentWinStreak[msg.sender];
        _bestWinStreak = bestWinStreak[msg.sender];
    }

    /// @notice Métricas globais básicas
    function globalStats()
        external
        view
        returns (
            uint256 _totalUniqueUsers,
            uint256 _totalInteractions
        )
    {
        _totalUniqueUsers = totalUniqueUsers;
        // total interactions aqui seria caro somar; então expomos apenas por usuário.
        // se quiser um contador global, adicione `uint256 public totalInteractions;` e incremente no play().
        _totalInteractions = 0;
    }

    // ====== Internals ======

    /// @dev Random fraco: miner/validator pode influenciar. OK só para jogo casual sem valor.
    function _contractMove(address user) internal view returns (Move) {
        uint256 r = uint256(
            keccak256(
                abi.encodePacked(
                    block.prevrandao,     // melhor que blockhash, mas ainda não é oracle
                    block.timestamp,
                    block.number,
                    user,
                    address(this)
                )
            )
        ) % 3;

        return Move(r);
    }

    function _result(Move u, Move c) internal pure returns (Result) {
        if (u == c) return Result.Draw;

        // u ganha de c?
        // Rock beats Scissors, Paper beats Rock, Scissors beats Paper
        if (
            (u == Move.Rock && c == Move.Scissors) ||
            (u == Move.Paper && c == Move.Rock) ||
            (u == Move.Scissors && c == Move.Paper)
        ) {
            return Result.Win;
        }

        return Result.Lose;
    }
}
