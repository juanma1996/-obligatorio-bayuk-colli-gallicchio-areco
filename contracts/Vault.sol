// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Vault{

    address public tokenContract;

    constructor(){}

    function setTokenContract(address newAddress) public {
        tokenContract = newAddress;
    }

    function _mint(address account, uint256 amount) internal virtual {
        bytes memory mintToken = abi.encodeWithSignature("_mint(address, uint256)", account, amount);
        tokenContract.call(mintToken);
    }
}