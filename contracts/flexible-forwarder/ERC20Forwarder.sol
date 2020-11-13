pragma solidity ^0.7.0;

import "../IERC20.sol";
import "./IForwarder.sol";

contract ERC20Forwarder is IForwarder {

    function forwardAndDestruct(address payable _wallet, address _token) external override {
        IERC20 tokenContract = IERC20(_token);
        uint256 balance = tokenContract.balanceOf(address(this));
        tokenContract.transfer(_wallet, balance);
        selfdestruct(_wallet);
    }
}