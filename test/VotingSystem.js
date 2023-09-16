const VotingSystem = artifacts.require("VotingSystem");
const { ethers } = require('ethers');

contract("VotingSystem", (accounts) => {
    let votingSystemInstance;
    const authorizedUser = accounts[1]; // Assume this address is authorized
    const wallet = ethers.Wallet.createRandom();
    const privateKey = wallet.privateKey;
    const voterAddress = accounts[2];
    const candidateId = 0; 


    before(async () => {
        votingSystemInstance = await VotingSystem.deployed();
    });

    it("should not allow unauthorized user to decrypt and count votes", async () => {
        console.log("Testing unauthorized user...");
        try {
            const result = await votingSystemInstance.countVotes(privateKey, { from: accounts[0] }); // Unauthorized user
            console.log("Result:", result);
            assert.fail("Unauthorized user was able to decrypt and count votes.");
        } catch (error) {
            console.log("Error:", error.message);
            assert(error.message.includes("Unauthorized user."), "Wrong error message.");
        }
    });

    it("should allow authorized user to decrypt and count votes", async () => {
        console.log("Testing authorized user...");
        // Ensure that 'authorizedUser' is authorized to decrypt and count votes
        const isAuthorized = await votingSystemInstance.isAuthorized(authorizedUser);
        console.log("Is authorized:", isAuthorized);
        assert.equal(isAuthorized, true, "Unauthorized user.");

        // Attempt to decrypt and count votes as an authorized user
        const decryptedVotes = await votingSystemInstance.countVotes(privateKey, { from: authorizedUser });
        console.log("Decrypted votes:", decryptedVotes);
        
        // Add assertions for the expected behavior when authorized user decrypts and counts votes
        // (For this basic example, we won't validate actual decryption logic)
        // assert(...) 
    });

    it("should allow a registered voter to cast a vote", async () => {
        // Register the voter
        await votingSystemInstance.registerVoter(voterAddress);

        // Ensure that the voter is registered
        const isRegistered = await votingSystemInstance.isRegistered(voterAddress);
        assert.equal(isRegistered, true, "Voter is not registered.");

        // Check if the voter has not voted yet
        const hasAlreadyVoted = await votingSystemInstance.hasVoted(voterAddress);
        assert.equal(hasAlreadyVoted, false, "Voter has already voted.");

        // Encrypt the vote with the private key
        const wallet = new ethers.Wallet(privateKey);
        const encryptedCandidateID = await wallet.signMessage(candidateId);
        
        // Cast the vote for a specific candidate (adjust candidateId as needed)
        await votingSystemInstance.vote(encryptedCandidateID, { from: voterAddress });

        // Check if the voter's vote has been recorded
        const hasVoted = await votingSystemInstance.hasVoted(voterAddress);
        assert.equal(hasVoted, true, "Voter's vote was not recorded.");
    });
});
