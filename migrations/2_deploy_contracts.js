// var ConvertLib = artifacts.require("./ConvertLib.sol");
// var MetaCoin = artifacts.require("./MetaCoin.sol");

var UCCoinVerifyUnion = artifacts.require("./UCCoinVerifyUnionTruffle.sol");

module.exports = function(deployer) {
  deployer.deploy(UCCoinVerifyUnion);
};
