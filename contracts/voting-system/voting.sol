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

    mapping(address => bool) voterWhitelist;
    uint private _voterWhitelistedCount = 0;

    mapping(address => Proposal) voterProposals;
    
    function adminWhitelist(address _addrVoter) external onlyOwner{

        // TODO: can whitelist the admin ? 


        require(!voterWhitelist[_addrVoter], "The voter is already whitelisted.");

        voterWhitelist[_addrVoter] = true;
        _voterWhitelistedCount++;
        emit VoterRegistered(_addrVoter);
    }

    function adminStartProposalsSession() external onlyOwner{

        require(_voterWhitelistedCount > 1, "Need at least 2 whitelisted voter to start a proposal session.");


    }



    function voterProposal(string calldata _description) external {
        
        require(voterWhitelist[msg.sender], "The voter must be whitelisted to make a proposal.");

        // One proposal only ? if yes add require

        voterProposals[msg.sender] = Proposal(_description, 0);

        // TODO:
        // emit ProposalRegistered();
    }






    function getWinner() public {

    }
}