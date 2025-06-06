// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PiggyBank {
    // 🔒 Stores the owner address
    address public owner;

    // 📢 Events to track key actions
    event Deposited(address indexed from, uint amount);
    event Withdrawn(address indexed to, uint amount);
    event ShowBalance(uint balance);

    // 🏗️ Constructor sets the owner during deployment
    constructor(address _owner) payable {
        owner = _owner;
    }

    // 🔐 Modifier to restrict functions to the owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // 📡 Emits the contract's current balance
    function showBalance() public {
        
        emit ShowBalance(address(this).balance);
    }

    // 💸 Withdraws all funds to the owner
    function withdraw() public onlyOwner {
        uint amount = address(this).balance;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    // 💰 Accept ETH deposits directly
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    // 🧲 Fallback function to handle unexpected calls
    fallback() external payable {
    emit Deposited(msg.sender, msg.value);
        }
}
