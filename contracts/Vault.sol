// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Vault{

    address private tokenContract;
    uint256 private maxAmountToTransfer;
    address private _tokenContract;
    mapping(address => bool) private _admins;

    constructor(){
        _admins[msg.sender] = true;
    }

    function setTransferAccount(address newAddress) public {
        _tokenContract = newAddress;
    }

    function mint(uint256 amount) public returns (bool success) {
        bytes memory mintToken = abi.encodeWithSignature("mint(uint256)", amount);
        (bool _success, bytes memory _returnData) = _tokenContract.call(mintToken);
        return _success;
    }

    // onlyAdmin modifier that validates only 
    // if caller of function is contract admin, 
    // otherwise not
    modifier onlyAdmin() 
    {
        require(isAdmin(),
        "Function accessible only by an admin");
        _;
    }
    
    // function for admins to verify their are an admin. 
    // Returns true for admins otherwise false
    function isAdmin() public view returns(bool) 
    {
        return _admins[msg.sender];
    }

    function addAdmin(address _admin) onlyAdmin public returns (bool success){
        _admins[_admin] = true;
        return true;
    }

    function removeAdmin(address _admin) onlyAdmin public returns (bool success){
        _admins[_admin] = false;
        return true;
    }

    function getMaxAmountToTransfer() view external returns (uint256) {
        return maxAmountToTransfer;
    }

    function setMaxAmountToTransfer(uint256 maxAmount) external {
        require(maxAmount > 0, "Max amount should be a positive number");
        require(maxAmount < 2^256, "Max amount should be minor than uint limit");
        //checkear si es admin
        maxAmountToTransfer = maxAmount;
    }

    function exchangeEther(uint256 _tokensAmount) external {
        bytes memory burnTokens = abi.encodeWithSignature("transfer(uint256,address)", _tokensAmount, msg.sender);
        (bool _success, bytes memory _returnData) = tokenContract.call(burnTokens);
        if (_success) {
            //pagar según buyPrice
        }
    }
}