// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract VotingSystem {

    mapping(address => bool) public isRegistered;
    address[] public registeredVoters;
    mapping(address => bool) public hasVoted;
    address[] public addressVoted;
    
    event Voted(address indexed voter, uint indexed candidateId);
    event DebugLog(string message, address indexed voterAddress);
    event DebugCandidateId(uint indexed candidateId);
    

    struct Candidate {
        uint id;
        string name;
        string affiliation;
        uint voteCount;
    }

    Candidate[] public candidates;

    constructor(string[] memory candidateNames, string[] memory candidateAffiliations) {
        require(candidateNames.length == candidateAffiliations.length, "Mismatch between names and affiliations.");
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate(i, candidateNames[i], candidateAffiliations[i], 0));
        }
    }

    function registerVoter(address voterAddress) public {
        // Only the contract owner or an authorized entity should be able to register voters
        // TODO: add access control mechanism
        emit DebugLog("Registering voter", voterAddress);
        registeredVoters.push(voterAddress);
        isRegistered[voterAddress] = true;
        hasVoted[voterAddress] = false;
        emit DebugLog("Voter registered", voterAddress);
    }

    function getRegisteredVotersCount() public view returns (uint) {
        return registeredVoters.length;
    }

    function isAuthorized(address caller) public pure returns (bool) {
        // for demonstration we assume we have a list of authorized personnel
        address[] memory authorizedAddresses = new address[](1);
        authorizedAddresses[0] = 0xeEfcDAD9Eadcd1E1cb9Ea466bbC635796940D073;
        for (uint i = 0; i < authorizedAddresses.length; i++) {
            if (authorizedAddresses[i] == caller) {
                return true;
            }
        }
        return false;
    }


    function vote(uint candidateId) public {
        require(isRegistered[msg.sender], "Voter is not registered.");
        require(!hasVoted[msg.sender], "Voter has already voted.");
        require(candidateId < candidates.length, "Invalid candidate ID.");

        hasVoted[msg.sender] = true;
        addressVoted.push(msg.sender);

        candidates[candidateId].voteCount++;
        emit Voted(msg.sender, candidateId);
    }

    function countVotes(uint candidateId) public view returns (uint) {
        require(isAuthorized(msg.sender), "Unauthorized user.");
        require(candidateId < candidates.length, "Invalid candidate ID.");
        
        return candidates[candidateId].voteCount;
    }
}