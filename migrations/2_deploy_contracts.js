var RedFoxMigration = artifacts.require("./RedFoxMigration.sol");
var Token = artifacts.require("./Token.sol");
module.exports = function(deployer) {
  deployer.deploy(RedFoxMigration);  
  
};
