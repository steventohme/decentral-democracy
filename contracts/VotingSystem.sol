// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract VotingSystem {

    mapping(string => mapping(string => mapping(string => bool))) public isRegistered;
    mapping(address => bool) public isRegisteredAddress;
    mapping(address => bool) public hasVoted;
    address[] public registeredAddresses;
    
    event Voted(address indexed voter, uint indexed candidateId);
    event VoterRegistered(address indexed voterAddress, string name, string surname, string dob);
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

    function registerVoter(string memory name, string memory surname, string memory dob) public {
        require(!isRegistered[name][surname][dob], "Voter is already registered.");

        address voterAddress = msg.sender;
        isRegistered[name][surname][dob] = true;
        registeredAddresses.push(voterAddress);
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
    //     function hexStringToBytes32(string memory hexString) private pure returns (bytes32) {
    //     bytes32 result;
    //     bytes memory hexBytes = bytes(hexString);

    //     for (uint i = 0; i < hexBytes.length; i += 2) {
    //         uint8 a = uint8(hexBytes[i]);
    //         uint8 b = uint8(hexBytes[i + 1]);
    //         require(a >= 48 && a <= 102 && b >= 48 && b <= 102, "Invalid hex string");
    //         uint8 c = a > 57 ? a - 87 : a - 48;
    //         uint8 d = b > 57 ? b - 87 : b - 48;
    //         result |= bytes32(c * 16 + d) >> (i / 2 * 8);
    //     }

    //     return result;
    // }

    function verifySignature(address signer, string memory signature) private pure returns (bool){
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", signer));
        bytes32 signatureHash = bytes32(abi.encodePacked(signature));

        address recoveredAddress = ecrecover(messageHash, 27, signatureHash, bytes32(0));

        return recoveredAddress == signer;
    }


    function vote(string memory voterAddressString, uint candidateId, string memory signature) public {
        address voterAddress = address(bytes20(bytes(voterAddressString)));
        require(isRegisteredAddress[voterAddress], "Voter is not registered.");
        require(!hasVoted[voterAddress], "Voter has already voted.");
        require(candidateId < candidates.length, "Invalid candidate ID.");

        require(verifySignature(voterAddress, signature), "Signature verification failed.");
        hasVoted[voterAddress] = true;

        candidates[candidateId].voteCount += 1;
        emit Voted(voterAddress, candidateId);

    }

    function countVotes(uint candidateId) public view returns (uint) {
        require(isAuthorized(msg.sender), "Unauthorized user.");
        require(candidateId < candidates.length, "Invalid candidate ID.");
        
        return candidates[candidateId].voteCount;
    }
}