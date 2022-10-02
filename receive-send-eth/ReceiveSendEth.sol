// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ReceiveSendEth {
    address public owner;
    uint public balance;

    constructor() {
        owner=msg.sender;
    }

    receive() payable external{
        balance+=msg.value;
    }

    function withdraw(address payable addr, uint amount) public {
        require(owner==msg.sender, "Only owner can withdraw.");
        require(amount<=balance, "Balance is not enough.");
        addr.transfer(amount);
        balance-=amount;
    }
}