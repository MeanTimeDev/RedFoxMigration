# RedFoxMigration

The migration system constists of two contracts Token.sol and RedFoxMigration.sol.
Token.sol implements a standard ERC20 token. The deployment process should be as follows:
RedFoxMigration.sol should be deployed.

Token.sol should be deployed. In the constructor function an array of objects containing an address and a token amount can be passed in, these tokens will be distributed when the contract is created. One of these objects should be the RedFoxMigration contract crediting with the total amount of tokens to be distributed by it.

RedFoxMigration.setTokenContract should be called passing in the deployed Token.sol address.

## Populate the token distibution lists
The list of addresses to be paid tokens should be populated.
RedFoxMigration allows allocation to two types of addresses which are stored in mappings in the contract. An ethereum address and a 20 byte hash which is the RipeMD160 encoded part of an bitcoin structured address (Raddress). Both types of address can be derived from an uncompressed Public key split into x and y coordinates. All primary functions within the contract are interacted with passing in the x and y coordinates from the public key.

Population of the lists is done using the following functions whcih can only be called by the contract owner:

setRAccountBalance(bytes20 account, TimedBalance[] memory balances)
setEthAccountBalance(address ethAddress, TimedBalance[] memory balances)

The TimedBalance structure is as follows:
struct TimedBalance {
    uint256 blockHeight;
    uint256 amount;
    bool paid;
}

Where blockHeight is the blockheight after which the tokens will become available, amount are the number of tokens and the paid flag which should always be passed in as false. 

setRAccountBalances & setEthAccountBalances allows the user to pass an array of accounts and TimedBalances to the contract.

## View and Withdraw Tokens

Retrieving token balances and completing withdrawals are done by passing in the x and y coordinates from the public key. The functions calculate both the ethereum address and the Raddress and then use these to look up their token allocation in the internal mappings.

totalAccountBalance(bytes32 publicKeyX,bytes32 publicKeyY) is used to retrieve the balance of both the Ethereum and Raddresses associated with the public key. The returned object is as follows:
struct AccountStatus {
    uint256 pending;   //token balance pending allocation, the block height has not been reached 
    uint256 available; //tokens currently available for withdrawal
    uint256 released;  //tokens that have been released
}

withdrawBalance(bytes32 publicKeyX,bytes32 publicKeyY) is used to withdraw all available tokens. The function transfers the tokens from the contract to the eth address for the public key. The function checks that the RedFoxMigration contract has enough tokens before transferring.





