// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleMultiSig
/// @notice Sistema básico de múltiplas assinaturas (N-de-M)
contract SimpleMultiSig {
    address public owner;
    address[] public signers;
    mapping(address => bool) public isSigner;
    uint256 public threshold;
    
    uint256 public totalUniqueUsers;
    mapping(address => bool) public hasInteracted;
    mapping(address => uint256) public interactionsCount;

    error NotOwner();
    error NotSigner();
    error InvalidThreshold();
    error AlreadySigner();
    error NotASigner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlySigner() {
        if (!isSigner[msg.sender]) revert NotSigner();
        _;
    }

    constructor(address[] memory _signers, uint256 _threshold) {
        require(_signers.length > 0, "Must have at least one signer");
        require(_threshold > 0 && _threshold <= _signers.length, "Invalid threshold");
        
        owner = msg.sender;
        threshold = _threshold;
        
        for (uint256 i = 0; i < _signers.length; i++) {
            require(_signers[i] != address(0), "Invalid signer address");
            require(!isSigner[_signers[i]], "Duplicate signer");
            
            isSigner[_signers[i]] = true;
            signers.push(_signers[i]);
        }
        
        _registerInteraction(msg.sender);
    }

    function _registerInteraction(address _user) internal {
        if (!hasInteracted[_user]) {
            hasInteracted[_user] = true;
            totalUniqueUsers += 1;
        }
        interactionsCount[_user] += 1;
    }

    event SignerAdded(address indexed signer, uint256 newSignerCount, uint256 threshold);
    event SignerRemoved(address indexed signer, uint256 newSignerCount, uint256 threshold);
    event ThresholdChanged(uint256 oldThreshold, uint256 newThreshold);

    function addSigner(address _signer) external onlyOwner {
        if (_signer == address(0)) revert NotASigner();
        if (isSigner[_signer]) revert AlreadySigner();
        
        isSigner[_signer] = true;
        signers.push(_signer);
        
        _registerInteraction(msg.sender);
        
        emit SignerAdded(_signer, signers.length, threshold);
    }

    function removeSigner(address _signer) external onlyOwner {
        if (!isSigner[_signer]) revert NotASigner();
        if (threshold > signers.length - 1) revert InvalidThreshold();
        
        isSigner[_signer] = false;
        
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == _signer) {
                signers[i] = signers[signers.length - 1];
                signers.pop();
                break;
            }
        }
        
        _registerInteraction(msg.sender);
        
        emit SignerRemoved(_signer, signers.length, threshold);
    }

    function setThreshold(uint256 _newThreshold) external onlyOwner {
        require(_newThreshold > 0 && _newThreshold <= signers.length, "Invalid threshold");
        
        uint256 oldThreshold = threshold;
        threshold = _newThreshold;
        
        _registerInteraction(msg.sender);
        
        emit ThresholdChanged(oldThreshold, _newThreshold);
    }

    receive() external payable {}
}

