// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Vault{

    address private tokenContract;
    uint256 private maxAmountToTransfer;

    constructor(){}

    function setTransferAccount(address newAddress) public {
        tokenContract = newAddress;
    }

    function mint(uint256 amount) public returns (bool success) {
        bytes memory mintToken = abi.encodeWithSignature("mint(uint256)", amount);
        (bool _success, bytes memory _returnData) = tokenContract.call(mintToken);
        return _success;
    }

    function setMaxAmountToTransfer(uint256 maxAmount) external {
        require(maxAmount > 0, "Max amount should be a positive number");
        require(maxAmount < 2^256, "Max amount should be minor than uint limit");
        //checkear si es admin
        maxAmountToTransfer = maxAmount;
    }
}