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
    
  })

});