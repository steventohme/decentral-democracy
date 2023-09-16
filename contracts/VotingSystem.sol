// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    address[] public voters;
    mapping(address => bool) public hasVoted;

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
        voters.push(voterAddress);
    }

}