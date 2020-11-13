pragma solidity ^0.7.0;

import "./PermanentForwarder.sol";

contract PermanentForwarderFactory {

    address public implementation;
    bytes public initCode;

    constructor() {
        implementation = address(new PermanentForwarder());
        initCode = _getInitCode(implementation);
    }

    function getForwarder(address _wallet) public view returns (address forwarder) {
        bytes32 salt = keccak256(abi.encodePacked(_wallet));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(abi.encodePacked(initCode))));
        forwarder = address(uint160(uint256(hash)));
    }

    function deployForwarder(address payable _wallet) external {
        PermanentForwarder forwarder = _deployForwarder(_wallet);
        forwarder.init(_wallet);
    }

    function forward(address payable _wallet, address _token) external {
        address forwarder = getForwarder(_wallet);
        PermanentForwarder(forwarder).forward(_token);
    }

    function _deployForwarder(address _wallet) internal returns (PermanentForwarder forwarder) {
        
        // load the init code to memory
        bytes memory mInitCode = initCode;

        // compute the salt from the destination
        bytes32 salt = keccak256(abi.encodePacked(_wallet));

        assembly {
            forwarder := create2(0, add(mInitCode, 0x20), mload(mInitCode), salt)
            if iszero(extcodesize(forwarder)) { revert(0, 0) }
        }
    }

    function _getInitCode(address _implementation) internal pure returns (bytes memory code) {
        bytes20 targetBytes = bytes20(_implementation);
        code = new bytes(55);
        assembly {
            mstore(add(code, 0x20), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(code, add(0x20,0x14)), targetBytes)
            mstore(add(code, add(0x20,0x28)), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
        }
    }
}