//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract PurchaseAgreement{
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State { created, locked, Release, Inactive }
    State public state;

    constructor() payable {
        seller = payable(msg.sender);
        value  = msg.value / 2;
    }

    //the function cannot be called at the current state
    error InvalidState();
    //only the buyer can call this function
    error OnlyBuyer();
    //only the seller can call this function
    error OnlySeller();

    modifier inState (State state_){
        if(state != state_){
            revert InvalidState();
        }
        _;
    }

    modifier onlyBuyer() {
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }
    modifier onlySeller() {
        if(msg.sender != seller){
            revert OnlySeller();
        }
        _;
    }

    function confirmPurchase() external inState(State.created) payable{
        require(msg.value == (2 * value),"please send it 2* the purchase amount");
        buyer = payable(msg.sender);
        state = State.locked;
    }

    function confirmReceived() external onlyBuyer inState(State.locked) {
        state = State.Release;
        buyer.transfer(value);
    }

    function paySeller() external onlySeller inState(State.Release){ 
        state = State.Inactive;
        seller.transfer(3 * value);
    }

    function abort() external onlySeller inState(State.created) {
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
}