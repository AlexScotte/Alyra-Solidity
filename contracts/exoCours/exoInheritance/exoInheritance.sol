// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract Parent {

    uint myValue;

    function setValue(uint _value) external{
        myValue = _value;
    }
}

contract Child is Parent{

    function getParentValue() external view returns(uint) {

        return myValue;
    }

}

contract Caller{

    function createChild(uint _value) public returns(uint){

        Child child = new Child();
        child.setValue(_value);
        return child.getParentValue();
    }
}