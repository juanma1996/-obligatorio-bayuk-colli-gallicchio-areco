// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Vault{

    address private _tokenContract;
    uint256 public buyPrice;
    uint256 public sellPrice;
    uint256 private maxAmountToTransfer;
    uint256 private _maxPercentageWithdraw;
    mapping(address => bool) private _admins;
    event Received(address, uint);
    mapping (uint256 => uint256) _mintMultisign;
    address payable[] private _adminsList;

    struct Withdraw{
        uint256 _amount;
        uint256 _signs;
    }

    Withdraw private _withdraw;

    constructor() payable{
        _admins[msg.sender] = true;
        _adminsList[0] = payable(msg.sender);
    }

     function setTransferAccount(address newAddress) onlyAdmin public {
        require(_tokenContract == address(0), "ERC20: Token Contract Account is not empty");
        require(newAddress != address(0), "ERC20: Token Contract Account zero address");
        _tokenContract = newAddress;
    }

    function mint(uint256 amount) public returns (bool success) {
        _mintMultisign[amount]++;
        if(_mintMultisign[amount] == 2){
            _mintMultisign[amount] = 0;
            bytes memory mintToken = abi.encodeWithSignature("mint(uint256)", amount);
            (bool _success, bytes memory _returnData) = _tokenContract.call(mintToken);
            require(_success == true);
            return _success;
        }

        return false;       
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
        _adminsList[_adminsList.length] = payable(msg.sender);
        return true;
    }

    function removeAdmin(address _admin) onlyAdmin public returns (bool success){
        _admins[_admin] = false;
        bool adminFound = false;
        for (uint256 index = 0; index < _adminsList.length; index++) {
            if(_adminsList[index] == msg.sender){
                _adminsList[index] = _adminsList[_adminsList.length - 1];
                adminFound = true;
                break;
            }
        }

        if(adminFound){
            delete _adminsList[_adminsList.length - 1];
        }
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

    function getMaxAmountToTransfer() view external returns (uint256) {
        return maxAmountToTransfer;
    }

    function setMaxAmountToTransfer(uint256 maxAmount) external {
        require(maxAmount > 0, "Max amount should be a positive number");
        require(maxAmount < 2^256, "Max amount should be minor than uint limit");
        require(isAdmin(), "Set Max amount should be accesed by administrator");
        maxAmountToTransfer = maxAmount;
    }

    function exchangeEther(uint256 tokensAmount) external payable {
        bytes memory transferTokens = abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), tokensAmount);
        (bool transferSuccess, bytes memory transferReturnData) = _tokenContract.call(transferTokens);
        require(transferSuccess == true);
        if (transferSuccess) {
            uint256 amountToTransfer = tokensAmount * buyPrice;
            payable(msg.sender).transfer(amountToTransfer);
        }
    }

    receive() external payable {
        require (msg.value > 0, "Should deposit ethers to buy tokens");
        uint256 amountToTransfer = msg.value/sellPrice;
        bytes memory transferTokens = abi.encodeWithSignature("transferFrom(address,address,uint256)", address(this), msg.sender, amountToTransfer);
        (bool transferSuccess, bytes memory transferReturnData) = _tokenContract.call(transferTokens);
        require(transferSuccess == true);
        if (transferSuccess) {
            emit Received(msg.sender, msg.value);
        }
    }

    function setMaxPercentage(uint8 _maxPercentage) onlyAdmin external{
        if (_maxPercentage <= 50){
            _maxPercentageWithdraw = _maxPercentage;
        }
    }

    function requestWithdraw(uint256 _amount) onlyAdmin public{
        if (_withdraw._amount != 0){
            require (_withdraw._amount == _amount, "Can't start two withdrawal operations simultaneous");
        }

        _withdraw._amount = _amount;
        _withdraw._signs++;
        if (_withdraw._signs == 2){
            withdraw();
        }
    }

    function withdraw() onlyAdmin public{
        require (_withdraw._signs == 2, "Two admin request withdrawals needed");
        uint256 percentage = _withdraw._amount * 100 / address(this).balance;
        require(percentage <= _maxPercentageWithdraw, "The percentage to be withdrawn must not be greater than the maximum allowed");
        uint256 amountToTransfer = _withdraw._amount / _adminsList.length;
        for (uint256 index = 0; index < _adminsList.length; index++) {
            _adminsList[index].transfer(amountToTransfer);
        }
    }

    function burn(uint256 _amount,address payable _address) public{
        uint256 _ethersToSend = _amount / (buyPrice * 50 / 100);
        require (address(this).balance >= _ethersToSend, "The amount to be transferred is greater than what can currently be supported");
        _address.transfer(_ethersToSend);
    }
}