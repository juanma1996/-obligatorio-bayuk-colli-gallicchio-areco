// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Vault{

    address private tokenContract;
    uint256 public buyPrice;
    uint256 public sellPrice;
    uint256 public maxAmountToTransfer;
    address private _tokenContract;
    mapping(address => bool) private _admins;
    event Received(address, uint);

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

    function setSellPrice(uint256 _sellPrice) external {
        require(_sellPrice > 0, "Sell price should be a positive number");
        require(_sellPrice < 2^256, "Sell price should be minor than uint limit");
        require(isAdmin(), "Set Sell price should be accesed by administrator");
        sellPrice = _sellPrice;
    }

    function setBuyPrice(uint256 _buyPrice) external {
        require(_buyPrice > 0, "Buy price should be a positive number");
        require(_buyPrice < 2^256, "Buy price should be minor than uint limit");
        require(isAdmin(), "Set Buy price should be accesed by administrator");
        buyPrice = _buyPrice;
    }

    function setMaxAmountToTransfer(uint256 maxAmount) external {
        require(maxAmount > 0, "Max amount should be a positive number");
        require(maxAmount < 2^256, "Max amount should be minor than uint limit");
        require(isAdmin(), "Set Max amount should be accesed by administrator");
        maxAmountToTransfer = maxAmount;
    }

    function exchangeEther(uint256 tokensAmount) external payable {
        bytes memory transferTokens = abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), tokensAmount);
        (bool transferSuccess, bytes memory transferReturnData) = tokenContract.call(transferTokens);
        if (transferSuccess) {
            uint256 amountToTransfer = tokensAmount * buyPrice;
            payable(msg.sender).transfer(amountToTransfer);
        }
    }

    receive() external payable {
        require (msg.value > 0, "Should deposit ethers to buy tokens");
        uint256 amountToTransfer = msg.value/sellPrice;
        bytes memory transferTokens = abi.encodeWithSignature("transferFrom(address,address,uint256)", address(this), msg.sender, amountToTransfer);
        (bool transferSuccess, bytes memory transferReturnData) = tokenContract.call(transferTokens);
        if (transferSuccess) {
            emit Received(msg.sender, msg.value);
        }
    }
}