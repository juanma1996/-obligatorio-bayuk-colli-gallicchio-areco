// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Vault{

    address private _tokenContract;
    mapping(address => bool) private _admins;

    constructor(){}

    function setTransferAccount(address newAddress) public {
        _tokenContract = newAddress;
        _admins[msg.sender] = true;
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
}