pragma solidity ^0.7.0;

import "./IForwarder.sol";

contract ETHForwarder is IForwarder {

    function forwardAndDestruct(address payable _wallet, address /*_token*/) external override {
        uint256 balance = address(this).balance;
        _wallet.transfer(balance);
        selfdestruct(_wallet);
    }
}