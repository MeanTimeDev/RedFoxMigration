var RedFoxMigration = artifacts.require("./RedFoxMigration.sol");
var Token = artifacts.require("./Token.sol");
module.exports = function(deployer) {
  deployer.deploy(Token,"testcoin","TEST").then(() => {
    return deployer.deploy(RedFoxMigration,Token.address);
  });
  
};