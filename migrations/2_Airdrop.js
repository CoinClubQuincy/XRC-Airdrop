const Airdrop = artifacts.require("Airdrop");

module.exports = function (deployer) {
  deployer.deploy(Airdrop);
};