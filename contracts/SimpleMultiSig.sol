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

    uint256 public proposalCount;
    
    struct Proposal {
        uint256 id;
        address proposer;
        address target;
        uint256 value;
        bytes data;
        bool executed;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }
    
    mapping(uint256 => Proposal) public proposals;
    uint256[] public activeProposalIds;

    error NotOwner();
    error NotSigner();
    error InvalidThreshold();
    error AlreadySigner();
    error NotASigner();
    error InvalidProposal();
    error AlreadyApproved();
    error NotApproved();
    error InsufficientApprovals();
    error AlreadyExecuted();
    error ExecutionFailed();

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
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        address target,
        uint256 value
    );
    event ProposalApproved(uint256 indexed proposalId, address indexed approver, uint256 approvalCount);
    event ProposalExecuted(uint256 indexed proposalId, address indexed executor);
    event ProposalCancelled(uint256 indexed proposalId, address indexed canceller);

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

    function propose(address _target, uint256 _value, bytes calldata _data) 
        external 
        onlySigner 
        returns (uint256 proposalId) 
    {
        require(_target != address(0), "Invalid target");
        
        proposalId = ++proposalCount;
        
        Proposal storage p = proposals[proposalId];
        p.id = proposalId;
        p.proposer = msg.sender;
        p.target = _target;
        p.value = _value;
        p.data = _data;
        p.executed = false;
        p.approvalCount = 1;
        p.approvals[msg.sender] = true;
        
        activeProposalIds.push(proposalId);
        
        _registerInteraction(msg.sender);
        
        emit ProposalCreated(proposalId, msg.sender, _target, _value);
        emit ProposalApproved(proposalId, msg.sender, 1);
    }

    function approve(uint256 _proposalId) external onlySigner {
        Proposal storage p = proposals[_proposalId];
        
        if (p.id == 0) revert InvalidProposal();
        if (p.executed) revert AlreadyExecuted();
        if (p.approvals[msg.sender]) revert AlreadyApproved();
        
        p.approvals[msg.sender] = true;
        p.approvalCount += 1;
        
        _registerInteraction(msg.sender);
        
        emit ProposalApproved(_proposalId, msg.sender, p.approvalCount);
    }

    function execute(uint256 _proposalId) external {
        Proposal storage p = proposals[_proposalId];
        
        if (p.id == 0) revert InvalidProposal();
        if (p.executed) revert AlreadyExecuted();
        if (p.approvalCount < threshold) revert InsufficientApprovals();
        
        p.executed = true;
        
        _removeFromActiveProposals(_proposalId);
        
        (bool success, ) = p.target.call{value: p.value}(p.data);
        if (!success) revert ExecutionFailed();
        
        _registerInteraction(msg.sender);
        
        emit ProposalExecuted(_proposalId, msg.sender);
    }

    function cancel(uint256 _proposalId) external {
        Proposal storage p = proposals[_proposalId];
        
        if (p.id == 0) revert InvalidProposal();
        if (p.executed) revert AlreadyExecuted();
        
        require(
            msg.sender == p.proposer || msg.sender == owner,
            "Not authorized to cancel"
        );
        
        p.executed = true;
        _removeFromActiveProposals(_proposalId);
        
        _registerInteraction(msg.sender);
        
        emit ProposalCancelled(_proposalId, msg.sender);
    }

    function _removeFromActiveProposals(uint256 _proposalId) internal {
        for (uint256 i = 0; i < activeProposalIds.length; i++) {
            if (activeProposalIds[i] == _proposalId) {
                activeProposalIds[i] = activeProposalIds[activeProposalIds.length - 1];
                activeProposalIds.pop();
                break;
            }
        }
    }

    function getProposal(uint256 _proposalId)
        external
        view
        returns (
            uint256 id,
            address proposer,
            address target,
            uint256 value,
            bool executed,
            uint256 approvalCount,
            bool canExecute
        )
    {
        Proposal storage p = proposals[_proposalId];
        return (
            p.id,
            p.proposer,
            p.target,
            p.value,
            p.executed,
            p.approvalCount,
            !p.executed && p.approvalCount >= threshold
        );
    }

    function hasApproved(uint256 _proposalId, address _signer)
        external
        view
        returns (bool)
    {
        return proposals[_proposalId].approvals[_signer];
    }

    function getSigners() external view returns (address[] memory) {
        return signers;
    }

    function getActiveProposals() external view returns (uint256[] memory) {
        return activeProposalIds;
    }

    function getSignerCount() external view returns (uint256) {
        return signers.length;
    }

    function myInteractions() external view returns (uint256) {
        return interactionsCount[msg.sender];
    }

    receive() external payable {}
}

