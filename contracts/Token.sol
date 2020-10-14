// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;
pragma experimental ABIEncoderV2;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    struct InitialAllocations {
        address account;
        uint256 amount;
    }

    string public name;
    string public symbol;
    uint8 public decimals = 18;


    constructor(string memory _name, string memory _symbol, InitialAllocations[] memory _initialAllocations) public {
        name = _name;
        symbol = _symbol;
        
        //loop through the initial allocations and mint the coins
        for(uint256 i = 0; i<_initialAllocations.length; i++){
            _mint(_initialAllocations[i].account,_initialAllocations[i].amount);    
        }
    }

}
