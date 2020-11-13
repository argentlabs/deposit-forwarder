pragma solidity ^0.7.0;

import "../IERC20.sol";

contract PermanentForwarder {

    address constant internal ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address payable wallet;

    function init(address payable _wallet) external {
        wallet = _wallet;
    }

    function forward(address _token) external {
        if (_token == ETH_TOKEN) {
            uint256 balance = address(this).balance;
            wallet.transfer(balance);
        } else {
            IERC20 tokenContract = IERC20(_token);
            uint256 balance = tokenContract.balanceOf(address(this));
            tokenContract.transfer(wallet, balance);
        }
    }
}