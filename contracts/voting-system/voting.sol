// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable{

    uint16 private winningProposalId;
    uint16 private votesCount;
    uint16 private voterRegisteredCount;

    mapping(address => Voter) private voters;
    mapping(address => uint[]) private voterProposalIds;
    Proposal[] private voterProposals;
    WorkflowStatus private currentVotingSession;

    event VoterRegistered(address indexed voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint16 indexed proposalId);
    event Voted (address indexed voter, uint16 indexed proposalId);

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
        uint16 votedProposalId;
    }

    struct Proposal {
        string description;
        uint16 voteCount;
    }

    modifier onlyRegistered{
        require(voters[msg.sender].isRegistered, "You must be registered do this.");
        _;
    }

    /**
     * @dev Change the current status and generate an event with the previous and the new status.
     */
    function _changeWorkflowStatus(WorkflowStatus newStatus) private {

        WorkflowStatus previousStatus = currentVotingSession;
        currentVotingSession = newStatus;

        emit WorkflowStatusChange(previousStatus, currentVotingSession);
    }

    /**
     * @dev Allows only the adminstrator to add a new voter if the voter registration is started.  
     */
    function adminAddRegistered(address _addrVoter) external onlyOwner{

        require(currentVotingSession == WorkflowStatus.RegisteringVoters, "The registering voters is not opened yet.");
        require(!voters[_addrVoter].isRegistered, "The voter is already registered.");
        
        voters[_addrVoter] = Voter(true, false, 0);
        voterRegisteredCount++;

        emit VoterRegistered(_addrVoter);
    }

    /**
     * @dev Allows only the administrator to start the proposal session if the voter registration is started 
     *      and there is at least 2 registered voters.
     */
    function adminStartProposalsSession() external onlyOwner{

        require(currentVotingSession == WorkflowStatus.RegisteringVoters, "The registering voters is not opened yet.");
        require(voterRegisteredCount > 1, "Need at least two registered voters to start a proposal session.");

        _changeWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted);
    }

    /**
     * @dev Allows only the administrator to stop the proposal session if the proposal registration is started
     *      and there is at least 2 proposals.
     */
    function adminStopProposalsSession() external onlyOwner{

        require(currentVotingSession == WorkflowStatus.ProposalsRegistrationStarted, "The proposal registration is not started yet.");
        require(voterProposals.length > 1, "Need at least two proposals to stop a proposal session.");

        _changeWorkflowStatus(WorkflowStatus.ProposalsRegistrationEnded);
    }

    /**
     * @dev Allows only the administrator to start the voting session if the proposal registration is started. 
     */
    function adminStartVotingSession() external onlyOwner{

        require(currentVotingSession == WorkflowStatus.ProposalsRegistrationEnded, "The proposal registration is not ended yet.");

        _changeWorkflowStatus(WorkflowStatus.VotingSessionStarted);
    }

    /**
     * @dev Allows only the administrator to stop the voting session if the voting session is started
     *      and there is at least one vote in a proposal. 
     */
    function adminStopVotingSession() external onlyOwner{

        require(currentVotingSession == WorkflowStatus.VotingSessionStarted, "The voting session is not started yet.");
        require(votesCount > 0, "Need at least one vote in a proprosal to stop a voting session.");

        _changeWorkflowStatus(WorkflowStatus.VotingSessionEnded);
    }

     /**
     * @dev Allows only the administrator to count the votes if the voting session is stopped. 
     *      In case of a tie, the winning proposal is the first found in the list 
     */
    function adminTallyVotes() external onlyOwner{
        require(currentVotingSession == WorkflowStatus.VotingSessionEnded, "The voting session is not ended yet.");

        for(uint16 i=0; i < voterProposals.length; i++){

            if(voterProposals[i].voteCount > voterProposals[winningProposalId].voteCount){
                winningProposalId = i;
            }
        }

        _changeWorkflowStatus(WorkflowStatus.VotesTallied);
    }





    /**
     * @dev Allows only a registered voter to add a proposal if the proposal registration is started
     *      and the description is not empty. 
     */
    function voterAddProposal(string calldata _description) external onlyRegistered {
        
        require(currentVotingSession == WorkflowStatus.ProposalsRegistrationStarted, "The proposal registration is not started yet.");
        require(bytes(_description).length > 0, "The proposal cannot be empty.");

        voterProposals.push(Proposal(_description, 0));
        uint16 proposalId = uint16(voterProposals.length - 1);
        voterProposalIds[msg.sender].push(proposalId);

        emit ProposalRegistered(proposalId);
    }

    /**
     * @dev Allows only a registered voter to vote if the voting session is started 
     *      and the user has not voted yet and the proposal id exists.
     */
    function voterAddVote(uint16 _proposalId) external onlyRegistered{

        require(currentVotingSession == WorkflowStatus.VotingSessionStarted, "The voting session is not started yet.");
        require(!voters[msg.sender].hasVoted, "You already voted.");
        require(_proposalId < voterProposals.length, "This proposal does not exists.");
        
        voters[msg.sender].votedProposalId = _proposalId;
        voters[msg.sender].hasVoted = true;
        voterProposals[_proposalId].voteCount++;
        votesCount++;

        emit Voted(msg.sender, _proposalId);
    }


    /**
     * @dev Allows everybody to check the winner if the vote count is over.
     * @return The winning proposal
     */
    function getWinner() external view returns(Proposal memory) {

        require(currentVotingSession == WorkflowStatus.VotesTallied, "The vote count is not over yet.");
    
        return voterProposals[winningProposalId];
    }

    /**
     * @dev Allows only a registered voter to check all the proposals of a registered voter.
     * @return The winning proposal
     */
    function getVoterProposals(address _addr) external view onlyRegistered returns(Proposal[] memory){
        
    require(voters[_addr].isRegistered, "The voter is not registered.");

        uint[] memory addrVoterProposalIds = voterProposalIds[_addr];
        Proposal[] memory addrVoterProposals = new Proposal[](addrVoterProposalIds.length);
        for(uint16 i=0; i<addrVoterProposalIds.length; i++){
            addrVoterProposals[i] = voterProposals[addrVoterProposalIds[i]];
        }

        return (addrVoterProposals);
    }

    /**
     * @dev Allows only a registered voter to check for which proposal a registered voter has voted.
     * @return The proposal for which the voter voted
     */
    function getVoterVote(address _addr) external view onlyRegistered returns(Proposal memory){

        require(voters[_addr].isRegistered, "The voter is not registered.");
        require(voters[_addr].hasVoted, "The voter has not voted yet.");

        return voterProposals[voters[_addr].votedProposalId];
    }
}