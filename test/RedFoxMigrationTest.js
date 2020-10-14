const assert = require('assert');

const RedFoxMigration = artifacts.require('RedFoxMigration.sol');
const Token = artifacts.require('Token.sol');

contract('RedFoxMigration', function (accounts) {

  it('Should create a token, associate it with a new migration contract and allocate it tokens',async () => {
    const redFoxMigrationInstance = await RedFoxMigration.deployed();
    const RedFoxM = await RedFoxMigration.new();
    const tokenInstance = await Token.deployed();
    //set the redfox token
    const token = await Token.new([[accounts[0],10000],[accounts[1],10000],[accounts[2],10000],[accounts[3],10000],[accounts[4],10000],[RedFoxM.address,1000000]]);
    await RedFoxM.setTokenContract(token.address);    
    //cehck the balances are correct
    const totalSupply = await token.totalSupply();
    const accountBalance = await token.balanceOf(accounts[1]);
    assert(accountBalance == 10000,"Account 0 supply does not equal 10000");
    assert(totalSupply == 1050000,"Total Supply does not add up");
    
    //Allocate tokens to accounts
    await RedFoxM.setEthAccountBalance(accounts[0],[["0","500",""],["10","1500",""],["50","2500",""]]);
    await RedFoxM.setEthAccountBalances([[accounts[1],[["0","500",""],["10","1500",""],["50","2500",""]]],[accounts[2],[["0","500",""],["10","1500",""],["50","2500",""]]],[accounts[3],[["0","500",""],["10","1500",""],["50","2500",""]]]]);
    //these need to be set in truffle
    let publicKeyX = "0xA0026437E9D994FB0D81E741C2EB90C0C230C926FBAA8CDB5D0E34AAEA7F488F";
    let publicKeyY = "0x2E6C9AC76939E7CFA263477AEBD55FE7B791F1B4E30682A272C2209CADC6C769";
    //Need to make sure that the Ripemd160 has been instantiated prior to calling this
    //1 Wei can be sent to the 0x03 contract to warm it up.
    const testBalance = await RedFoxM.totalAccountBalance(publicKeyX,publicKeyY);
    console.log(testBalance);
  })

});