// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract VotingSystem {
    address[] public voters;
    mapping(address => bool) public isRegistered;
    mapping(address => bool) public hasVoted;
    mapping(address => bytes) public encryptedVotes;
    
    event Voted(address indexed voter, uint indexed candidateId);
    event DebugLog(string message, address indexed voterAddress);
    

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
        voters.push(voterAddress);
        isRegistered[voterAddress] = true;
        emit DebugLog("Voter registered", voterAddress);
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

    // both of these function are encrypted with XOR for simplicity and demonstration purposes
    // production would have more robust encryption
    function vote(bytes memory encryptedCandidateId) public {
        require(isRegistered[msg.sender], "Voter is not registered.");
        require(!hasVoted[msg.sender], "Voter has already voted.");

        bytes memory key = bytes("secret");
        bytes memory candidateIdBytes = new bytes(encryptedCandidateId.length);
        for (uint i = 0; i < encryptedCandidateId.length; i++) {
            candidateIdBytes[i] = encryptedCandidateId[i] ^ key[i % key.length];
        }

        // Convert the decrypted candidate ID bytes to a uint
        uint candidateId = abi.decode(candidateIdBytes, (uint));

        // Ensure that the candidate ID is valid
        require(candidateId < candidates.length, "Invalid candidate ID.");

        // Record the encrypted candidate ID as the vote
        encryptedVotes[msg.sender] = encryptedCandidateId;
        hasVoted[msg.sender] = true;

        // Increment the vote count for the selected candidate
        candidates[candidateId].voteCount++;

        emit Voted(msg.sender, candidateId);
    }

    function countVotes(bytes memory encryptedCandidateId) public view returns (uint[] memory) {
        require(isAuthorized(msg.sender), "Unauthorized user.");
        
        // Decrypt the encrypted candidate ID to obtain the candidate ID
        bytes memory key = bytes("secret");
        bytes memory candidateIdBytes = new bytes(encryptedCandidateId.length);
        for (uint i = 0; i < encryptedCandidateId.length; i++) {
            candidateIdBytes[i] = encryptedCandidateId[i] ^ key[i % key.length];
        }

        // Convert the decrypted candidate ID bytes to a uint
        uint candidateId = abi.decode(candidateIdBytes, (uint));

        // Ensure that the candidate ID is valid
        require(candidateId < candidates.length, "Invalid candidate ID.");

        // Create an array to store the vote counts for each candidate
        uint[] memory voteCounts = new uint[](candidates.length);

        // Retrieve and return the vote count for the specified candidate
        voteCounts[candidateId] = candidates[candidateId].voteCount;

        return voteCounts;
    }

}