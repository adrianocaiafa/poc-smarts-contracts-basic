// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleInteractions
/// @notice Conta quantos endereços únicos interagiram com o contrato
contract SimpleMessages {
    // Total de usuários únicos que já interagiram
    uint256 public totalUniqueUsers;

    // Marca se um endereço já interagiu pelo menos 1 vez
    mapping(address => bool) public hasInteracted;

    // Quantas vezes cada endereço já interagiu
    mapping(address => uint256) public interactionsCount;

    // Guarda a última mensagem enviada por cada endereço
    mapping(address => string) public lastMessage;

    // Guarda TODAS as mensagens em array (opcional, mas útil)
    string[] public messageFeed;

    event MessageSent(address indexed user, string message, uint256 totalUniqueUsers);

    /// @notice Envia uma mensagem on-chain
    /// @dev Isso GERA transação real e altera storage
    function postMessage(string calldata _message) external {
        require(bytes(_message).length > 0, "Mensagem vazia nao permitida");

        // Conta usuário único se for a primeira interação
        if (!hasInteracted[msg.sender]) {
            hasInteracted[msg.sender] = true;
            totalUniqueUsers += 1;
        }

        // Incrementa contador de interações
        interactionsCount[msg.sender] += 1;

        // Guarda a última mensagem enviada pelo usuario
        lastMessage[msg.sender] = _message;

        // Armazena no feed global
        messageFeed.push(_message);

        emit MessageSent(msg.sender, _message, totalUniqueUsers);
    }

    /// @notice Quantas mensagens totais foram enviadas?
    function totalMessages() external view returns (uint256) {
        return messageFeed.length;
    }

    /// @notice Retorna TODAS as mensagens (cuidado com gas se houver muitas)
    function getAllMessages() external view returns (string[] memory) {
        return messageFeed;
    }
    
    /// @notice Helper pra ver quantas vezes VOCÊ já chamou o contrato
    function myInteractions() external view returns (uint256) {
        return interactionsCount[msg.sender];
    }
}
