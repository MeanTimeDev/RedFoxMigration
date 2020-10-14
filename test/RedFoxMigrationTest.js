const assert = require('assert');

const RedFoxMigration = artifacts.require('RedFoxMigration.sol');
const Token = artifacts.require('Token.sol');

contract('RedFoxMigration', function (accounts) {

  it('Should create a token and then initiate the migration',async () => {
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
    //const redfoxSupply = await RedFoxM.checkTokenBalance();
    //assert(redfoxSupply == 1000000,"Redfox supply should be 1000000");
  })
/*
  it('Should create an ethereum and bitcoin address from a public key',async() => {
    //let one_eth = web3.eth.toWei(1, "ether");0x05 84 f1 44 0d 6F 7e 5A E5 Eb e5 6D 3d dE 74 B8 5d EF c0 C7
    await web3.eth.sendTransaction({from: accounts[1], to: "0x0300000000000000000000", value: 0.000001});
        
    const tokenInstance = await Token.deployed();
    const token = await Token.new("FOX test","FOXT",{});
    
    console.log("Coin address:",token.address);
    const redFoxMigrationInstance = await RedFoxMigration.deployed();
    const RedFoxM = await RedFoxMigration.new(tokenInstance.address);
    
    let publicKey = "0x03bec65f0142c31d91702a05ac145f39599804e52a294d2b89ecd38fd01ab50890";
    let ethAddress = await RedFoxM.getEthereumAddress.call(publicKey);
    console.log("EthAddress:",ethAddress);
    let btcaddress = await RedFoxM.getBitcoinAddress.call(publicKey);
    //console.log("BTCAddress:",btcaddress);
    let ripemdtest = await RedFoxM.testRipeMD160.call();
    let balance = 
    console.log("ripemd:",ripemdtest);
  })*/

});