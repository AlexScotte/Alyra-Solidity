// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract Random {

    uint256 private _nonce = 0;
    uint _lastRand;

    function random() public returns(uint){
        _nonce++;
        _lastRand = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _nonce))) % 100;
        return _lastRand;
    }

    function getLastRandomForTest() public view returns (uint){
        return _lastRand;
    }
}