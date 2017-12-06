// var ConvertLib = artifacts.require("./ConvertLib.sol");
// var MetaCoin = artifacts.require("./MetaCoin.sol");

var UCCoin_VerifyUnion = artifacts.require("./UCCoin_VerifyUnion.sol");

module.exports = function(deployer) {
  deployer.deploy(UCCoin_VerifyUnion);
};
