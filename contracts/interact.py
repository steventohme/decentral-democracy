from web3 import Web3, HTTPProvider, contract
import json

# Connect to a local Ethereum node (replace with your node's URL)
w3 = Web3(HTTPProvider("http://127.0.0.1:7545"))

# Ensure the connection is successful
if not w3.isConnected():
    print("Failed to connect to the Ethereum node.")
    exit()

print("Connected to Ethereum node")

# Replace with the path to your contract's JSON ABI file and contract address
contract_abi_path = '../build/contracts/VotingSystem.json'
contract_address = '0x30EAa006eF9D1BC0333abA61A4e94aB442106DAd'

with open(contract_abi_path) as f:
    contract_abi = json.load(f)["abi"]

# Create a contract instance
voting_system_contract = w3.eth.contract(abi=contract_abi, address=contract_address)

# Main function
def main():
    accounts = w3.eth.accounts
    candidate_id = 1
    voter_address = accounts[2]

    # Register a voter
    register_voter_receipt = voting_system_contract.functions.registerVoter(voter_address).transact({'from': accounts[0], 'gas': 3000000})
    is_registered_status = voting_system_contract.functions.isRegistered(voter_address).call()

    print('Is Registered:', is_registered_status)

    # Cast a vote
    vote_receipt = voting_system_contract.functions.vote(candidate_id).transact({'from': voter_address})
    has_voted_status = voting_system_contract.functions.hasVoted(voter_address).call()
    print('Has Voted:', has_voted_status)

    print('Register Voter Receipt Status:', w3.eth.waitForTransactionReceipt(register_voter_receipt)['status'])
    print('Vote Receipt Status:', w3.eth.waitForTransactionReceipt(vote_receipt)['status'])

    print('Voter registered and vote cast successfully.')

if __name__ == '__main__':
    main()
