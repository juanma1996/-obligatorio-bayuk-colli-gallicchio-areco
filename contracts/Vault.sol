// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Vault{

    address private tokenContract;

    constructor(){}

    function setTransferAccount(address newAddress) public {
        tokenContract = newAddress;
    }

    function _mint(uint256 amount) public returns (bool success) {
        bytes memory mintToken = abi.encodeWithSignature("mint(uint256)", amount);
        (bool _success, bytes memory _returnData) = tokenContract.call(mintToken);
        return _success;
    }
}