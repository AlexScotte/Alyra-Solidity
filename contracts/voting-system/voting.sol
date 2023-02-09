// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract voting is Ownable{

    uint256 private winningProposalId;

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
    uint private _voterRegisteredCount = 0;

    mapping(address => uint[]) voterProposalIds;
    Proposal[] voterProposals;
    
    WorkflowStatus private _currentVotingSession;

    uint private _votesCount = 0;

    function _changeWorkflowStatus(WorkflowStatus newStatus) private {

        WorkflowStatus previousStatus = _currentVotingSession;
        _currentVotingSession = newStatus;

        emit WorkflowStatusChange(previousStatus, _currentVotingSession);
    }


    function adminAddRegistered(address _addrVoter) external onlyOwner{

        require(_currentVotingSession == WorkflowStatus.RegisteringVoters, "The registering voters is not opened yet.");
        require(!voters[_addrVoter].isRegistered, "The voter is already registered.");
        
        voters[_addrVoter] = Voter(true, false, 0);
        _voterRegisteredCount++;

        emit VoterRegistered(_addrVoter);
    }

    function adminStartProposalsSession() external onlyOwner{

        require(_currentVotingSession == WorkflowStatus.RegisteringVoters, "The registering voters is not opened yet.");
        require(_voterRegisteredCount > 1, "Need at least two registered voters to start a proposal session.");

        _changeWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted);
    }

    function adminStopProposalsSession() external onlyOwner{

        require(_currentVotingSession == WorkflowStatus.ProposalsRegistrationStarted, "The proposal registration is not started yet.");
        require(voterProposals.length > 1, "Need at least two proposals to stop a proposal session.");

        _changeWorkflowStatus(WorkflowStatus.ProposalsRegistrationEnded);
    }

    function adminStartVotingSession() external onlyOwner{

        require(_currentVotingSession == WorkflowStatus.ProposalsRegistrationEnded, "The proposal registration is not ended yet.");

        _changeWorkflowStatus(WorkflowStatus.VotingSessionStarted);
    }

    
    function adminStopVotingSession() external onlyOwner{

        require(_currentVotingSession == WorkflowStatus.VotingSessionStarted, "The voting session is not started yet.");
        require(_votesCount > 0, "Need at least one vote in a proprosal to stop a voting session.");

        _changeWorkflowStatus(WorkflowStatus.VotingSessionEnded);
    }

    function adminTallyVotes() external onlyOwner{
        require(_currentVotingSession == WorkflowStatus.VotingSessionEnded, "The voting session is not ended yet.");

        // TODO: Manage equality
        uint256 votesCount = 0;
        for(uint i=0; i < voterProposals.length; i++){

            if(voterProposals[i].voteCount > votesCount){
                winningProposalId = i;
            }
        }

        _changeWorkflowStatus(WorkflowStatus.VotesTallied);
    }



    function voterAddProposal(string calldata _description) external {
        
        require(_currentVotingSession == WorkflowStatus.ProposalsRegistrationStarted, "The proposal registration is not started yet.");
        require(voters[msg.sender].isRegistered, "You must be registered to make a proposal.");
        require(bytes(_description).length > 0, "The proposal cannot be empty.");


        voterProposals.push(Proposal(_description, 0));
        uint proposalId = voterProposals.length - 1;
        voterProposalIds[msg.sender].push(proposalId);

        emit ProposalRegistered(proposalId);
    }

    function voterAddVote(uint _proposalId) external{

        require(_currentVotingSession == WorkflowStatus.VotingSessionStarted, "The voting session is not started yet.");
        require(voters[msg.sender].isRegistered, "You must be registered to vote.");
        require(!voters[msg.sender].hasVoted, "You already voted.");
        require(bytes(voterProposals[_proposalId].description).length > 0, "This proposal does not exists.");
        
        voters[msg.sender].votedProposalId = _proposalId;
        voters[msg.sender].hasVoted = true;
        voterProposals[_proposalId].voteCount++;
        _votesCount++;

        emit Voted(msg.sender, _proposalId);
    }

    function getWinner() public view returns(Proposal memory) {

        require(_currentVotingSession == WorkflowStatus.VotesTallied, "The vote count is not over yet.");
    
        return voterProposals[winningProposalId];
    }
}