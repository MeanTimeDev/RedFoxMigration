// SPDX-License-Identifier: MIT
// Redfox migration 

pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RedFoxMigration is Ownable{
    
    struct TimedBalance {
        uint256 blockHeight;
        uint256 amount;
        bool paid;
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

    function setEthAccountBalances(SetEthBalance[] memory balances) public onlyOwner{
        for (uint i=0; i < balances.length; i++){
            setEthAccountBalance(balances[i].account,balances[i].balances);
        }
    }

    function setEthAccountBalance(address ethAddress, TimedBalance[] memory balances) public onlyOwner{
        for(uint256 i = 0; i < balances.length; i++){
            _ebalances[ethAddress].push(balances[i]);
        }
    }

    function getEthAccountBalances(address ethAddress) public view returns (TimedBalance[] memory) {
        return _ebalances[ethAddress];
    }

    function getRAccountBalances(bytes20 rAddress) public view returns (TimedBalance[] memory) {
        return _rbalances[rAddress];
    }
    
    function getEthAccountAvailable(address ethAddress) public view returns(uint256){
        return availableAmount(_ebalances[ethAddress]);
    }

    function getRAccountAvailable(bytes20 account) public view returns (uint256) {
        return availableAmount(_rbalances[account]);
    }

    function balanceOf(bytes32 publicKeyX,bytes32 publicKeyY) public view returns (uint256) {
        uint256 totalBalance = 0;
        bytes20 accountReference = getAccountReference(publicKeyX,publicKeyY);
        address ethAddress = getEthereumAddress(publicKeyX,publicKeyY);
        totalBalance += getRAccountAvailable(accountReference);
        totalBalance += getEthAccountAvailable(ethAddress);
        return totalBalance;
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
    
    function availableAmount(TimedBalance[] memory balances) private view returns (uint256) {
        uint256 totalBalance = 0;
        uint256 currentBlockHeight = block.number;
        for(uint256 i = 0; i < balances.length; i++){
            if(currentBlockHeight >= balances[i].blockHeight && balances[i].paid == false){
                totalBalance += balances[i].amount;
            }
        }
        return totalBalance;
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

