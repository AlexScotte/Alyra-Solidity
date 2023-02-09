// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract exoBalance {

    address myAdress;

    function setAddresse(address _addr) public{

        myAdress = _addr;
    }

    function getBalance() public view returns(uint){

        return myAdress.balance;
    }

    function getABalance(address _addr) public view returns(uint){

        return _addr.balance;
    }

    function transferBalance(address _addr) public payable returns(bool){

        (bool success,) = _addr.call{value: msg.value}("");
        return success;
    }

    
    function transferBalanceCheck(uint amount) public payable returns(bool){

        require(msg.value > 1, "You need to send more money.");
        require(myAdress.balance > amount, "Not enough money to send.");
        (bool success,) = myAdress.call{value: msg.value}("");
        return success;
    }
}