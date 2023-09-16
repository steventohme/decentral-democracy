// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/cryptography/ECDSA.sol";

contract VotingSystem {
    address[] public voters;
    mapping(address => bool) public isRegistered;
    mapping(address => bool) public hasVoted;

    event Voted(address indexed voter, uint indexed candidateId);
    event DebugLog(string message, address indexed voterAddress);

    using ECDSA for bytes32;
    mapping(address => bytes) public encryptedVotes;

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

    function vote(bytes memory encryptedVote) public {
        require(isRegistered[msg.sender], "Voter is not registered.");
        require(!hasVoted[msg.sender], "Voter has already voted.");

        bytes32 encryptionKey =  keccak256(abi.encodePacked(block.timestamp, msg.sender));
        bytes memory encrypted = ECDSA.secp256k1Encrypt(encryptedVote, encryptionKey);

        encryptedVotes[msg.sender] = encrypted;

        hasVoted[msg.sender] = true;
    }
}