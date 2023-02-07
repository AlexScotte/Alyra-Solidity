// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract voting is Ownable{

    // uint256 private winningProposalId;

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    mapping(address => Voter) voters;
    uint private _voterWhitelistedCount = 0;

    mapping(address => uint) voterProposalIds;
    Proposal[] voterProposals;
    
    WorkflowStatus private _currentVotingSession;

    function adminWhitelist(address _addrVoter) external onlyOwner{

        // TODO: can whitelist the admin ? 


        require(!voters[_addrVoter].isRegistered, "The voter is already whitelisted.");
        
        voters[_addrVoter] = Voter(true, false, 0);
        _voterWhitelistedCount++;

        emit VoterRegistered(_addrVoter);
    }

    function adminStartProposalsSession() external onlyOwner{

        require(_voterWhitelistedCount > 1, "Need at least 2 whitelisted voter to start a proposal session.");

        WorkflowStatus previousStatus = _currentVotingSession;
        _currentVotingSession = WorkflowStatus.ProposalsRegistrationStarted;

        emit WorkflowStatusChange(previousStatus, _currentVotingSession);
    }

    function adminStopProposalsSession() external onlyOwner{

        // require(_voterWhitelistedCount > 1, "Need at least 2 whitelisted voter to start a proposal session.");
        require(_currentVotingSession == WorkflowStatus.ProposalsRegistrationStarted, "The proposal registration is not started yet.");

        WorkflowStatus previousStatus = _currentVotingSession;        
        _currentVotingSession = WorkflowStatus.ProposalsRegistrationEnded;

        emit WorkflowStatusChange(previousStatus, _currentVotingSession);
    }

    function adminStartVotingSession() external onlyOwner{

        require(voterProposals.length > 1, "Need at least 2 proposals to start a voting session.");

        WorkflowStatus previousStatus = _currentVotingSession;
        _currentVotingSession = WorkflowStatus.VotingSessionStarted;

        emit WorkflowStatusChange(previousStatus, _currentVotingSession);
    }




    function voterAddProposal(string calldata _description) external {
        
        require(_currentVotingSession == WorkflowStatus.ProposalsRegistrationStarted, "The proposal registration is not started yet.");
        require(voters[msg.sender].isRegistered, "You must be whitelisted to make a proposal.");
        require(bytes(_description).length > 0, "The proposal cannot be empty.");

        // One proposal only ? if yes add require

        voterProposals.push(Proposal(_description, 0));
        uint proposalId = voterProposals.length - 1;
        voterProposalIds[msg.sender] = proposalId;

        emit ProposalRegistered(proposalId);
    }

    function voterAddVote(uint _proposalId) external{

        require(_currentVotingSession == WorkflowStatus.VotingSessionStarted, "The voting session is not started yet.");
        require(voters[msg.sender].isRegistered, "You must be whitelisted to vote.");
        require(voters[msg.sender].hasVoted, "You already voted.");
        require(bytes(voterProposals[_proposalId].description).length > 0, "This proposal does not exists.");
        
        voters[msg.sender].votedProposalId = _proposalId;
        voters[msg.sender].hasVoted = true;
    }





    function getWinner() public {

    }
}