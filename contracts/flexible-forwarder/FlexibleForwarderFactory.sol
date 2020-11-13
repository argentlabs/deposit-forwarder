pragma solidity ^0.7.0;

import "./IForwarder.sol";
import "./ETHForwarder.sol";
import "./ERC20Forwarder.sol";

contract FlexibleForwarderFactory {

    address constant internal ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public ethImplementation;
    address public erc20Implementation;
    bytes private initCode;
    bytes32 private initCodeHash; 

    mapping (address => address) implementations;

    constructor() public {
        ethImplementation = address(new ETHForwarder());
        erc20Implementation = address(new ERC20Forwarder());
        initCode = (hex"5860208158601c335a63aaf10f428752fa158151803b80938091923cf3");
        initCodeHash = keccak256(abi.encodePacked(initCode));
    }

    function getForwarder(address _wallet) public view returns (address forwarder) {
        bytes32 salt = keccak256(abi.encodePacked(_wallet));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, initCodeHash));
        forwarder = address(uint160(uint256(hash)));
    }

    function forward(address payable _wallet, address _token) external {
        address implementation = _token == ETH_TOKEN ? ethImplementation : erc20Implementation;
        IForwarder forwarder = _deployForwarder(implementation, _wallet);
        forwarder.forwardAndDestruct(_wallet, _token);
    }

    function _deployForwarder(address _implementation, address _wallet) internal returns (IForwarder deployedForwarder) {
        
        // load the init code to memory
        bytes memory mInitCode = initCode;

        // compute the salt from the destination
        bytes32 salt = keccak256(abi.encodePacked(_wallet));

        // get the expected address for the forwarder
        address forwarder = getForwarder(_wallet);

        // store the implementation for the forwarder
        implementations[forwarder] = _implementation;

        // using inline assembly: load data and length of data, then call CREATE2.
        /* solhint-disable no-inline-assembly */
        assembly {
            let encoded_data := add(0x20, mInitCode) // load initialization code.
            let encoded_size := mload(mInitCode)     // load the init code's length.
            deployedForwarder := create2( // call CREATE2 with 4 arguments.
                0,                                    // do not forward any endowment.
                encoded_data,                         // pass in initialization code.
                encoded_size,                         // pass in init code's length.
                salt                                  // pass in the salt value.
            )
        } /* solhint-enable no-inline-assembly */

        // delete the stored implementation to save some gas
        delete implementations[forwarder];

        require(forwarder == address(deployedForwarder), "Failed to deploy forwarder");
    }

    function getImplementation() external view returns (address implementation) {
        return implementations[msg.sender];
    }
}