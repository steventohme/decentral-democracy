const VotingSystem = artifacts.require("VotingSystem");

contract("VotingSystem", (accounts) => {
    let votingSystemInstance;

    before(async () => {
        votingSystemInstance = await VotingSystem.deployed();
    });

    it("should allow a voter to register", async () => {
        const voterAddress = accounts[0];
        await votingSystemInstance.registerVoter(voterAddress);
        const isRegistered = await votingSystemInstance.isRegistered(voterAddress);
        assert.equal(isRegistered, true, "Voter was not registered.");
    });

    it("should allow a voter to cast a vote", async () => {
        const voterAddress = accounts[1];
        const candidateId = 0;
        await votingSystemInstance.registerVoter(voterAddress);
        await votingSystemInstance.vote(candidateId, { from: voterAddress });
        const hasVoted = await votingSystemInstance.hasVoted(voterAddress);
        assert.equal(hasVoted, true, "Voter was not able to cast a vote.");
    });
});
