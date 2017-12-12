// var ConvertLib = artifacts.require("./ConvertLib.sol");
// var MetaCoin = artifacts.require("./MetaCoin.sol");

var UCCoinVerifyUnion = artifacts.require("./UCCoinVerifyUnion.sol");

module.exports = function(deployer) {
  deployer.deploy(UCCoinVerifyUnion);
};
