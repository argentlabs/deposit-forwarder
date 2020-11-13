pragma solidity ^0.7.0;

interface IForwarder {
    function forwardAndDestruct(address payable _destination, address _token) external;
}