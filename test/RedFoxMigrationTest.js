const assert = require('assert');

const RedFoxMigration = artifacts.require('RedFoxMigration.sol');
const Token = artifacts.require('Token.sol');

contract('RedFoxMigration', function (accounts) {

  it('Should create a token and then initiate the migration',async () => {
    //const redFoxMigrationInstance = await RedFoxMigration.deployed();
    //const RedFoxM = await RedFoxMigration.new();
    const tokenInstance = await Token.deployed();
    /*const token = await Token.new("FOX test","FOXT",[[accounts[0],10000]]);
    
    //console.log("Coin address:",token.address);
    let contractBalance = await tokenInstance.balanceOf(accounts[0]);
    console.log(contractBalance);*/
    //let ripemdBalance = await address("0x03").transfer(1);
    //assert(contractBalance=1000,"Incorrect account balance");
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