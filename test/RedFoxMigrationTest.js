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
    await RedFoxM.setEthAccountBalance(accounts[0],[["0","500",""],["10","1500",""],["5000000000","2500",""]]);
    await RedFoxM.setEthAccountBalances([[accounts[1],[["0","500",""],["10","1500",""],["5000000000","2500",""]]],[accounts[2],[["0","500",""],["10","1500",""],["50","2500",""]]],[accounts[3],[["0","500",""],["10","1500",""],["50","2500",""]]]]);
    //these need to be set in truffle
    let publicKeyX = "0x560e9ee8c6a914a024122f358afd46599e1fb988682972e9dd124928fbd22394";
    let publicKeyY = "0x5cbf4233d05e670166cc90c3aa2b3481c9cee981e923bd37ad6a100bad47bc75";
    //Need to make sure that the Ripemd160 has been instantiated prior to calling this
    //1 Wei can be sent to the 0x03 contract to warm it up.
    const compressedKey = await RedFoxM.getCompressedPublicKey(publicKeyX,publicKeyY);
    assert(compressedKey =="0x03560e9ee8c6a914a024122f358afd46599e1fb988682972e9dd124928fbd22394","Compressed Key is incorrect");
    let available = await RedFoxM.getEthAccountAvailable(accounts[0]);
    assert(available == 2000,"Accounts[0] available is not equal to 2000");
    
    //finalize contract this should fail
    await RedFoxM.finalizeImport();
    await RedFoxM.setEthAccountBalances([[accounts[1],[["0","500",""],["10","1500",""],["5000000000","2500",""]]],[accounts[2],[["0","500",""],["10","1500",""],["50","2500",""]]],[accounts[3],[["0","500",""],["10","1500",""],["50","2500",""]]]]);    

  })

});