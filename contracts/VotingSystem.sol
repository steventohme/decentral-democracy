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
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate(i, candidateNames[i], candidateAffiliations[i], 0));
        }
    }

    function registerVoter(string memory name, string memory surname, string memory dob) public {
        require(isRegistered[name][surname][dob] == false, "Voter with same details already registered");

        address voterAddress = msg.sender;
        isRegistered[name][surname][dob] = true;
        isRegisteredAddress[voterAddress] = true;
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

    function verifySignature(address signer, string memory signature) private pure returns (bool){
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", signer));
        bytes32 signatureHash = bytes32(abi.encodePacked(signature));

        address recoveredAddress = ecrecover(messageHash, 27, signatureHash, bytes32(0));

        return recoveredAddress == signer;
    }

    function convertToAddress(string memory hexString) public pure returns (address) {
        bytes memory hexBytes = bytes(hexString);
        require(hexBytes.length == 42, "Invalid address length");
        uint160 convertedAddress;
        
        for (uint i = 2; i < hexBytes.length; i++) {
            uint8 digit = uint8(hexBytes[i]);
            if (digit >= 48 && digit <= 57) {
                digit -= 48;
            } else if (digit >= 65 && digit <= 70) {
                digit -= 55;
            } else if (digit >= 97 && digit <= 102) {
                digit -= 87;
            } else {
                revert("Invalid character in address");
            }
            convertedAddress = convertedAddress * 16 + uint160(digit);
        }
        
        return address(convertedAddress);
    }


    function vote(string memory voterAddressString, uint candidateId, string memory signature) public {
        address voterAddress = convertToAddress(voterAddressString);
        require(isRegisteredAddress[voterAddress] == true, "Voter is not registered.");
        require(hasVoted[voterAddress] == false, "Voter has already voted.");
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