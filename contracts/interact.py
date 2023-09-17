from web3 import Web3, HTTPProvider
from eth_account import Account
from eth_account.messages import encode_defunct
import json
import time

# Connect to a local Ethereum node
w3 = Web3(HTTPProvider("http://127.0.0.1:7545"))

# Replace with the path to your contract's JSON ABI file and contract address
contract_abi_path = '../build/contracts/VotingSystem.json'
contract_address = '0x9f50B64083a9477452b609b64F74c47776082c7b'

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
        if option == "R":
            register()
            break
        elif option == "V":
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

    print(receipt)
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
    register()
    vote()

# 0xb01ecBBf750E1C193F470632703cEdA68F932d90
# 1
# 0xb6fa6034793a3c299a5267fc902782af12d9988a4d91b1b6298fed4ae05fce8f
