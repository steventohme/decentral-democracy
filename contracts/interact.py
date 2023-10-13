from web3 import Web3, HTTPProvider
from eth_account import Account
from eth_account.messages import encode_defunct
import json
import time

# Connect to a local Ethereum node
w3 = Web3(HTTPProvider("http://127.0.0.1:7545"))

# Replace with the path to your contract's JSON ABI file and contract address
contract_abi_path = '../build/contracts/VotingSystem.json'
contract_address = '0xa051cd5cECc2A846ca80d0B9167dC1543bA084e0'

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
    option = input("To register as a voter, enter R. To vote, enter V. To exit, enter E. ")
    while option != "E":
        if option == "R" or option == "r":
            register()
            break
        elif option == "V" or option == "v":
            vote()
            break
        else:
            print("Invalid option. Please try again.")
            option = input("To register as a voter, enter R. To vote, enter V. To exit, enter E.")
    
    print("Thank you for using Decentral Democracy. Have a nice day!")

def register():
    voterName = input("Enter your first name: ")
    voterSurname = input("Enter your last name: ")
    voterDOB = input("Enter your date of birth (DD/MM/YY): ")

    registered_voters_count = voting_system_contract.functions.getRegisteredVotersCount().call()
    voter_address = w3.eth.accounts[registered_voters_count + 1]


    transaction_hash = voting_system_contract.functions.registerVoter(
        voterName, voterSurname, voterDOB).transact({'from': voter_address, 'gas': 3000000})

    while True:
        try:
            receipt = w3.eth.get_transaction(transaction_hash)
            if receipt.blockNumber is not None:
                break
        except Exception as e:
            print("Waiting for transaction to be mined...")
            time.sleep(1) 

    print("Your Ethereum address (public key) for voting is:", voter_address)
    return voter_address

def vote():
    voterAddress = input("Enter your Ethereum address (public key): ")
    privateKey = input("Enter your private key: ")
    candidateId = int(input("Enter the ID of the candidate you wish to vote for: "))

    # Generate a signature using the private key
    message_text = f"Vote for candidate {candidateId}"
    message = encode_defunct(text=message_text)
    signed_message = Account.sign_message(message, private_key=privateKey)

    # Send a transaction to the smart contract
    transaction_hash = voting_system_contract.functions.vote(
        voterAddress, candidateId, signed_message.signature.hex()
    ).transact({'from': w3.eth.accounts[0], 'gas': 3000000})

    while True:
        try:
            receipt = w3.eth.get_transaction(transaction_hash)
            if receipt.blockNumber is not None:
                break
        except Exception as e:
            print("Waiting for transaction to be mined...")
            time.sleep(1)

    print("Vote cast successfully.")


if __name__ == '__main__':
    sys()

# 0x8E4151ced6cEdE9ac2Ce0418DfdCB1b184B7Ba8a
# 1
# 0xb20fd910bda73c869d4d3ae0b114a31812cce9db5aed01a954a005b0714640fd
