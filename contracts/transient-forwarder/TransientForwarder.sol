pragma solidity ^0.7.0;

import "../IERC20.sol";

contract TransientForwarder {

    address constant internal ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function forwardAndDestruct(address payable _wallet, address _token) external {
        if (_token == ETH_TOKEN) {
            uint256 balance = address(this).balance;
            _wallet.transfer(balance);
        } else {
            IERC20 tokenContract = IERC20(_token);
            uint256 balance = tokenContract.balanceOf(address(this));
            tokenContract.transfer(_wallet, balance);
        }
        selfdestruct(_wallet);
    }
}