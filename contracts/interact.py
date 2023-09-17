from web3 import Web3, HTTPProvider
import json

# Connect to a local Ethereum node
w3 = Web3(HTTPProvider("http://127.0.0.1:7545"))

# Replace with the path to your contract's JSON ABI file and contract address
contract_abi_path = '../build/contracts/VotingSystem.json'
contract_address = '0x28DCa635551fd11b6b070a5DFBC5DCa1763f78e4'

with open(contract_abi_path) as f:
    contract_abi = json.load(f)["abi"]

# Create a contract instance
voting_system_contract = w3.eth.contract(abi=contract_abi, address=contract_address)

def sys():
    print("""
████████▄     ▄████████  ▄████████ ████████▄     ▄████████   ▄▄▄▄███▄▄▄▄   
███   ▀███   ███    ███ ███    ███ ███   ▀███   ███    ███ ▄██▀▀▀███▀▀▀██▄ 
███    ███   ███    █▀  ███    █▀  ███    ███   ███    █▀  ███   ███   ███ 
███    ███  ▄███▄▄▄     ███        ███    ███  ▄███▄▄▄     ███   ███   ███ 
███    ███ ▀▀███▀▀▀     ███        ███    ███ ▀▀███▀▀▀     ███   ███   ███ 
███    ███   ███    █▄  ███    █▄  ███    ███   ███    █▄  ███   ███   ███ 
███   ▄███   ███    ███ ███    ███ ███   ▄███   ███    ███ ███   ███   ███ 
████████▀    ██████████ ████████▀  ████████▀    ██████████  ▀█   ███   █▀  
                                                                           
""")
    print("Welcome to the Decentral Democracy")
    option = input("To register as a voter, enter R. To vote, enter V. To exit, enter E.")
    while option != "E":
        if option == "R":
            register()
        elif option == "V":
            vote()
        else:
            print("Invalid option. Please try again.")
            option = input("To register as a voter, enter R. To vote, enter V. To exit, enter E.")
    
    print("Thank you for using Decentral Democracy. Have a nice day!")


    

# Main function
def test():
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


    print('Register Voter Receipt Status:', has_voted_status)
    print('Vote Receipt Status:', vote_receipt)
    print('Voter registered and vote cast successfully.')

if __name__ == '__main__':
    Voting()

