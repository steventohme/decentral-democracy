const {Web3} = require('web3');
web3 = new Web3(new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545"));

console.log('web3')
const VotingSystem = require('../build/contracts/VotingSystem.json');
const contractAddress = '0x30EAa006eF9D1BC0333abA61A4e94aB442106DAd';
const votingSystemInstance = new web3.eth.Contract(VotingSystem.abi, contractAddress);
console.log('const')


async function main() {
  console.log('main')
  const accounts = await web3.eth.getAccounts();
  const candidateId = 1;
  const voterAddress = accounts[2];
  // Register a voter
  const registerVoterReceipt = await votingSystemInstance.methods.registerVoter(voterAddress).send({ from: accounts[0], gas: 3000000 });
  const isRegisteredStatus = await votingSystemInstance.methods.isRegistered(voterAddress).call();
  

  console.log('Is Registered:', isRegisteredStatus);


  // Cast a vote
  const voteReceipt = await votingSystemInstance.methods.vote(candidateId).send({ from: voterAddress });
  const hasVotedStatus = await votingSystemInstance.methods.hasVoted(voterAddress).call();
  console.log('Has Voted:', hasVotedStatus);

  console.log('Register Voter Receipt Status:', registerVoterReceipt.status);
  console.log('Vote Receipt Status:', voteReceipt.status);

  console.log('Voter registered and vote cast successfully.');
}

main();
