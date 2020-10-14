// SPDX-License-Identifier: MIT
// Redfox migration 

pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

/// @title RedFox Migration Contract
/// @author James Russell
/// @notice This contract allows for the allocation of ERC20 tokens to accounts identified by a public key

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RedFoxMigration is Ownable{
    
    struct TimedBalance {
        uint256 blockHeight;
        uint256 amount;
        bool paid;
    }
    
    struct AccountStatus {
        uint256 pending;
        uint256 available;
        uint256 released;
    }
    
    struct SetRBalance {
        bytes20 account;
        TimedBalance[] balances;
    }
    
    struct SetEthBalance {
        address account;
        TimedBalance[] balances;
    }
    
    address private _tokenContract;
    
    //for balances with an r address
    mapping (bytes20 => TimedBalance[]) private _rbalances;
    //for balances with an ethereum address
    mapping (address => TimedBalance[]) private _ebalances;

    event RedFoxMigrated(address account,uint256 amount);
    
    function setTokenContract(address tokenContract) public onlyOwner{
        _tokenContract = tokenContract;
    } 
    
    function getTokenContract() public view returns(address){
        return _tokenContract;
    }

    function checkTokenBalance() public view returns(uint256){
        ERC20 redFoxToken = ERC20(_tokenContract);
        return redFoxToken.balanceOf(address(this));
    }

    function setRAccountBalances(SetRBalance[] memory balances) public onlyOwner{
        for (uint i=0; i < balances.length; i++){
            setRAccountBalance(balances[i].account,balances[i].balances);
        }
    }

    function setRAccountBalance(bytes20 account, TimedBalance[] memory balances) public onlyOwner{
        for(uint256 i = 0; i < balances.length; i++){
            _rbalances[account].push(balances[i]);
        }
    }
    
    function setEthAccountBalance(address ethAddress, TimedBalance[] memory balances) public onlyOwner{
        for(uint256 i = 0; i < balances.length; i++){
            _ebalances[ethAddress].push(balances[i]);
        }
    }

    function setEthAccountBalances(SetEthBalance[] memory balances) public onlyOwner{
        for (uint i=0; i < balances.length; i++){
            setEthAccountBalance(balances[i].account,balances[i].balances);
        }
    }


    function getEthAccountBalances(address ethAddress) public view returns (TimedBalance[] memory) {
        return _ebalances[ethAddress];
    }

    function getRAccountBalances(bytes20 rAddress) public view returns (TimedBalance[] memory) {
        return _rbalances[rAddress];
    }
    
    function getEthAccountAvailable(address ethAddress) public view returns(uint256){
        AccountStatus memory eStatus = generateAccountStatus(_ebalances[ethAddress]);
        return eStatus.available;
    }

    function getRAccountAvailable(bytes20 account) public view returns (uint256) {
        AccountStatus memory rStatus = generateAccountStatus(_rbalances[account]);
        return rStatus.available;
    }
    
    function getEthAccountStatus(address ethAddress) public view returns(AccountStatus memory){
        return generateAccountStatus(_ebalances[ethAddress]);
    }

    function getRAccountStatus(bytes20 account) public view returns (AccountStatus memory) {
        return generateAccountStatus(_rbalances[account]);
    }
    

    function totalAccountBalance(bytes32 publicKeyX,bytes32 publicKeyY) public view returns (AccountStatus memory) {
        AccountStatus memory totalAccountStatus;
        bytes20 accountReference = getAccountReference(publicKeyX,publicKeyY);
        address ethAddress = getEthereumAddress(publicKeyX,publicKeyY);
        AccountStatus memory rStatus = getRAccountStatus(accountReference);
        AccountStatus memory eStatus = getEthAccountStatus(ethAddress);
        totalAccountStatus.pending = rStatus.pending + eStatus.pending;
        totalAccountStatus.available = rStatus.available + eStatus.available;
        totalAccountStatus.released = rStatus.released + eStatus.released;
        return totalAccountStatus;
    }

    function withdrawBalance(bytes32 publicKeyX,bytes32 publicKeyY) public {
        ERC20 redFoxToken = ERC20(_tokenContract);
        address ethAddress = getEthereumAddress(publicKeyX,publicKeyY);
        
        //check that the public key matches the msg.sender
        require(msg.sender == ethAddress,
            "msg.sender must equal the ethereum address from the public key");
        
        //retrieve the balance from the public key
        bytes20 accountRef = getAccountReference(publicKeyX,publicKeyY);
        uint256 withdrawAmount = getEthAccountAvailable(ethAddress) + getRAccountAvailable(accountRef);
        
        //check that the balance allocated to this contract is enough to cover the withdrawal
        require(redFoxToken.balanceOf(address(this))>=withdrawAmount,
            "Migration Contract has insufficient funds");
        
        //send the balance to the msg.sender
        redFoxToken.transfer(msg.sender,withdrawAmount);
        
        //mark the items as paid
        updateBalances(ethAddress,accountRef);
        emit RedFoxMigrated(msg.sender,withdrawAmount);
    }

    function getEthereumAddress(bytes32 publicKeyX,bytes32 publicKeyY) public pure returns(address addr){
        bytes32 hash = keccak256(abi.encodePacked(publicKeyX,publicKeyY));
        assembly {
            mstore(0, hash)
            addr := mload(0)
        }    
    }
    
    function getAccountReference(bytes32 publicKeyX,bytes32 publicKeyY) public pure returns(bytes20){
        bytes memory compressedPublicKey = getCompressedPublicKey(publicKeyX,publicKeyY);
        bytes32 firstSha256 = sha256(compressedPublicKey);
        bytes20 ripemd = ripemd160(abi.encodePacked(firstSha256));
        return ripemd;        
    }
    
    function getCompressedPublicKey(bytes32 publicKeyX,bytes32 publicKeyY) private pure returns(bytes memory){
        uint256 yAsInt = uint256(publicKeyY);
        uint8 yOdd = uint8(yAsInt&1);
        byte leadingByte;
        if(yOdd == 1) 
            leadingByte = 0x03; 
        else 
            leadingByte = 0x02;
        bytes memory cPublicKey = abi.encodePacked(leadingByte,publicKeyX);
        return cPublicKey;
    }
    
    function generateAccountStatus(TimedBalance[] memory balances) private view returns (AccountStatus memory) {
        uint256 currentBlockHeight = block.number;
        AccountStatus memory currentStatus;
        
        currentStatus.pending = 0;
        currentStatus.available = 0;
        currentStatus.released = 0;
        
        for(uint256 i = 0; i < balances.length; i++){
            if(currentBlockHeight >= balances[i].blockHeight && balances[i].paid == false){
                currentStatus.available += balances[i].amount;
            }
            if(balances[i].blockHeight >= currentBlockHeight && balances[i].paid == false){
                currentStatus.pending += balances[i].amount;
            }
            if(balances[i].paid == true){
                currentStatus.released += balances[i].amount;
            }
        }
        return currentStatus;
    }
    
    function updateBalances(address ethAddress,bytes20 accountRef) private {
        uint currentBlockHeight = block.number;
        for(uint256 i = 0; i < _ebalances[ethAddress].length; i++){
            if(currentBlockHeight >= _ebalances[ethAddress][i].blockHeight && !_ebalances[ethAddress][i].paid){
                _ebalances[ethAddress][i].paid = true;
            }
        }
        for(uint256 i = 0; i < _rbalances[accountRef].length; i++){
            if(currentBlockHeight >= _rbalances[accountRef][i].blockHeight && !_rbalances[accountRef][i].paid){
                _rbalances[accountRef][i].paid = true;
            }
        }
    }


}

