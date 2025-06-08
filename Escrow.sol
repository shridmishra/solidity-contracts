// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    // Addresses of the seller and buyer
    address public seller;
    address public buyer;
    
    // Amount of ETH deposited by buyer
    uint public amount;

    // Enum representing the contract state
    enum Status { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }
    Status public state;

    // Events to track contract activity
    event Deposited(address indexed buyer, uint amount);
    event DeliveryConfirmed(address indexed buyer);
    event Refunded(address indexed buyer, uint amount);

    // Constructor sets the buyer and seller addresses and initial state
    constructor(address _seller, address _buyer) {
        seller = _seller;
        buyer = _buyer;
        state = Status.AWAITING_PAYMENT;
    }

    // Modifier to restrict function access to seller only
    modifier onlySeller() {
        require(seller == msg.sender, "Only seller can call");
        _;
    }

    // Modifier to restrict function access to buyer only
    modifier onlyBuyer() {
        require(buyer == msg.sender, "Only buyer can call");
        _;
    }

    // Buyer deposits ETH, sets the amount, and moves state to AWAITING_DELIVERY
    function deposit() public payable onlyBuyer {
        require(state == Status.AWAITING_PAYMENT, "Already paid");
        require(msg.value > 0, "Deposit must be > 0");

        amount = msg.value;
        state = Status.AWAITING_DELIVERY;

        emit Deposited(msg.sender, msg.value);
    }

    // Buyer confirms delivery, sends ETH to seller and completes the contract
    function confirmDelivery(bool done) public onlyBuyer {
        require(state == Status.AWAITING_DELIVERY, "Nothing to confirm");
        require(done == true, "Must confirm true");

        state = Status.COMPLETE;
        payable(seller).transfer(amount);

        emit DeliveryConfirmed(msg.sender);
    }

    // Buyer can refund if delivery hasn't been confirmed yet
    function refund() public onlyBuyer {
        require(state == Status.AWAITING_DELIVERY, "Refund not possible now");

        state = Status.AWAITING_PAYMENT;
        payable(buyer).transfer(amount);

        emit Refunded(msg.sender, amount);
    }

    // Allow contract to receive ETH (fallback)
    receive() external payable {}
}
