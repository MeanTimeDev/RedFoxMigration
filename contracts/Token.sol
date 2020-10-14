// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    struct InitialAllocations {
        address account;
        uint256 amount;
    }

    constructor(InitialAllocations[] memory _initialAllocations) public ERC20("RFOX","RFOX"){
        //loop through the initial allocations and mint the coins
        for(uint256 i = 0; i<_initialAllocations.length; i++){
            _mint(_initialAllocations[i].account,_initialAllocations[i].amount);    
        }
    }

}
