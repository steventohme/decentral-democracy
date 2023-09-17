// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract VotingSystem {

    mapping(string => mapping(string => mapping(string => bool))) public isRegistered;
    mapping(address => bool) public hasVoted;
    address[] public registeredAddresses;
    mapping(address => VoterInfo) public voterInfo;
    
    event Voted(address indexed voter, uint indexed candidateId);
    event VoterRegistered(address indexed voterAddress, string name, string surname, string dob);
    event DebugCandidateId(uint indexed candidateId);
    
    struct VoterInfo {
        string voterName;
        string voterSurname;
        string voterDOB;
    }

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

    function registerVoter(string memory name, string memory surname, string memory dob) public {
        require(!isRegistered[name][surname][dob], "Voter is already registered.");

        address voterAddress = msg.sender;
        isRegistered[name][surname][dob] = true;
        registeredAddresses.push(voterAddress);
        voterInfo[voterAddress] = VoterInfo(name, surname, dob);
        hasVoted[voterAddress] = false;
        emit VoterRegistered(voterAddress, name, surname, dob);
    }

    function getRegisteredVotersCount() public view returns (uint) {
        return registeredAddresses.length;
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


    // function vote(uint candidateId) public {
    //     require(isRegistered[msg.sender], "Voter is not registered.");
    //     require(!hasVoted[msg.sender], "Voter has already voted.");
    //     require(candidateId < candidates.length, "Invalid candidate ID.");

    //     hasVoted[msg.sender] = true;
    //     addressVoted.push(msg.sender);

    //     candidates[candidateId].voteCount++;
    //     emit Voted(msg.sender, candidateId);
    // }

    function countVotes(uint candidateId) public view returns (uint) {
        require(isAuthorized(msg.sender), "Unauthorized user.");
        require(candidateId < candidates.length, "Invalid candidate ID.");
        
        return candidates[candidateId].voteCount;
    }
}