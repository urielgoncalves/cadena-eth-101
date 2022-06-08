// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Bank {
	//Declare state variables at contract level. 
	//State variables are stored on the blockchain and will cost gas.
	//The public keyword will allow anyone to access these variables, automatically creating a getter for us which will come in handy for our front-end
	//Other visibility modifiers include private, internal, and external.
    address public bankOwner;
    string public bankName; 
    
    //Mappings are like Objects in JavaScript, Dictionaries in Python, and Hashes in Ruby. 
    //They're always stored in storage, even if they're inside functions, because they're state variables
    mapping(address => uint256) public customerBalance; 
    
    //The constructor is only executed once, when the contract deploys 
    constructor() {
        //we're setting the bank owner to the Ethereum address that deploys the contract
        //msg.sender is a global variable that stores the address of the account that initiates a transaction
        bankOwner = msg.sender; //initialize state variable 
    }

    //Setter functions change the value of our state variables and cost gas. 
    //Getter functions allow us to get the return value of our state variable. 
    //Both will be used for our Dapp interface.
    
    //we have our modifier payable. 
    //As the name implies we need this modifier to recieve money in our contract.
    //https://blog.soliditylang.org/2020/03/26/fallback-receive-split/
    function depositMoney() public payable {
        //We could use if/else for our checks but require is preferred. 
        //Require is like a try, catch in javascript. 
        //First we check for the validity of a certain condition, and then we set the error if that condition isn't met.
        //msg is a global variable that allows us to access properties like the sender, the address that initiated the transaction, and value, the amount of Ether in wei being sent
        require(msg.value != 0, "You need to deposit some amount of money!");

        //we look through our customerBalance mappings to see if the address of the msg.sender exists and then add the total the deposited to their balance
        //mappings are more efficient than an array here, we would have had to loop through an array to find the msg.sender, which is costly on Ethereum
        customerBalance[msg.sender] += msg.value;
    }

    //We could use public but since we aren't calling this function any where in our contract, we can save gas using external
    //Parameters are also temporarily stored in memory.
    //for demonstration purposes by ensuring _name is stored in memory
    function setBankName(string memory _name) external {
        require(
            msg.sender == bankOwner,
            "You must be the owner to set the name of the bank"
        );
        bankName = _name;
    }

    function withdrawMoney(address payable _to, uint256 _total) public {
        require(
            _total <= customerBalance[msg.sender],
            "You have insuffient funds to withdraw"
        );

        customerBalance[msg.sender] -= _total;
        //The transfer function is built into Solidity and transfers money to an address
        //https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/
        _to.transfer(_total); 
    }

    function getCustomerBalance() external view returns (uint256) {
        return customerBalance[msg.sender];
    }

    function getBankBalance() public view returns (uint256) {
        require(
            msg.sender == bankOwner,
            "You must be the owner of the bank to see all balances."
        );
        return address(this).balance;
    }
}