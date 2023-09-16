pragma solidity ^0.8.0;

contract VotingSystem {
    address[] public voters;
    mapping(address => bool) public hasVoted;
}