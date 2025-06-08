// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    address public owner;

    enum VotingPhase { NotStarted, Ongoing, Ended }
    VotingPhase public phase;

    struct Candidate {
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;

    mapping(address => bool) public hasVoted;
    address[] public voters;

    uint public startTime;
    uint public endTime;

    event Voted(address indexed from, bool success);
    event CandidatesAdded(address indexed by, uint id);

    modifier OnlyOwner {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
        phase = VotingPhase.NotStarted;
    }

    // Start the voting process for a specific duration
    function startVoting(uint durationInSeconds) public OnlyOwner {
        require(phase == VotingPhase.NotStarted, "Already started");
        require(candidatesCount > 0, "Add candidates first");

        phase = VotingPhase.Ongoing;
        startTime = block.timestamp;
        endTime = block.timestamp + durationInSeconds;
    }

    // End voting manually (alternative to auto-end)
    function endVoting() public OnlyOwner {
        require(phase == VotingPhase.Ongoing, "Voting not active");
        phase = VotingPhase.Ended;
    }

    // Add candidates before voting starts
    function addCandidate(string memory _name) public OnlyOwner {
        require(phase == VotingPhase.NotStarted, "Can't add after voting starts");
        candidates[candidatesCount] = Candidate(_name, 0);
        emit CandidatesAdded(msg.sender, candidatesCount);
        candidatesCount++;
    }

    // Vote for a candidate by ID
    function vote(uint candidateId) public {
        require(phase == VotingPhase.Ongoing, "Voting not ongoing");
        require(block.timestamp <= endTime, "Voting has ended");
        require(!hasVoted[msg.sender], "Already voted");
        require(candidateId < candidatesCount, "Invalid candidate");

        candidates[candidateId].voteCount++;
        hasVoted[msg.sender] = true;
        voters.push(msg.sender);

        emit Voted(msg.sender, true);
    }

    // Get the candidate with the highest votes
    function getWinner() public view returns (string memory) {
        require(phase == VotingPhase.Ended, "Voting not ended");

        uint winnerId = 0;
        uint maxVotes = candidates[0].voteCount;

        for (uint i = 1; i < candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }

        return candidates[winnerId].name;
    }

    // Get all candidates who are tied with max votes
    function getTiedWinners() public view returns (string[] memory) {
        require(phase == VotingPhase.Ended, "Voting not ended");

        uint maxVotes = 0;
        for (uint i = 0; i < candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
            }
        }

        string[] memory tempWinners = new string[](candidatesCount);
        uint count = 0;

        for (uint i = 0; i < candidatesCount; i++) {
            if (candidates[i].voteCount == maxVotes) {
                tempWinners[count] = candidates[i].name;
                count++;
            }
        }

        string[] memory winners = new string[](count);
        for (uint i = 0; i < count; i++) {
            winners[i] = tempWinners[i];
        }

        return winners;
    }

    // View all candidates (useful for frontend)
    function getAllCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory result = new Candidate[](candidatesCount);
        for (uint i = 0; i < candidatesCount; i++) {
            result[i] = candidates[i];
        }
        return result;
    }

    // Reset all state to start fresh (after voting ends)
    function resetVoting() public OnlyOwner {
        require(phase == VotingPhase.Ended, "Voting must end first");

        for (uint i = 0; i < candidatesCount; i++) {
            delete candidates[i];
        }

        for (uint i = 0; i < voters.length; i++) {
            hasVoted[voters[i]] = false;
        }

        delete voters;
        candidatesCount = 0;
        startTime = 0;
        endTime = 0;
        phase = VotingPhase.NotStarted;
    }

    // Optional utility to auto-end based on time
    function checkAndEndVoting() public {
        if (phase == VotingPhase.Ongoing && block.timestamp > endTime) {
            phase = VotingPhase.Ended;
        }
    }
}
