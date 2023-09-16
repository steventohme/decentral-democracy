const VotingSystem = artifacts.require("VotingSystem");

module.exports = function (deployer) {
    deployer.deploy(VotingSystem, ["Donald Trump", "Joe Biden"], ["GOP", "DNC"]);
};
