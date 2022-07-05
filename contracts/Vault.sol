// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Vault{

    address private _tokenContract;
    uint256 public buyPrice;
    uint256 public sellPrice;
    uint256 public maxAmountToTransfer;
    uint256 private _maxPercentageWithdraw;
    mapping(address => bool) private _admins;
    event Received(address, uint);
    address private _farmContract;
    uint256 private _approvedWithdraws;
    mapping (uint256 => uint256) _withdrawHistory;
    mapping(address => uint256) private _adminsWithdrawsQnty;
    uint256 private _qntyAdmins;

    struct Mint{
        uint256 _signs;
        address _firstSigner;
    }

    struct Withdraw{
        uint256 _amount;
        uint256 _signs;
        address _firstSigner;
    }

    Withdraw private _withdraw;
    mapping (uint256 => Mint) _mintMultisign;

    constructor() payable{
        _admins[msg.sender] = true;
        _qntyAdmins++;
        _tokenContract = address(0);
    }

    function setTransferAccount(address newAddress) onlyAdmin public {
        require(_tokenContract == address(0), "Token Contract Account is not empty");
        require(newAddress != address(0), "Token Contract Account zero address");
        _tokenContract = newAddress;
    }

    function setFarmAccount(address newAddress) onlyAdmin public {
        require(_farmContract == address(0), "Farm Contract Account is not empty");
        require(newAddress != address(0), "Farm Contract Account zero address");
        _farmContract = newAddress;
    }

    function mint(uint256 amount) onlyAdmin public returns (bool success) {
        if (_mintMultisign[amount]._signs == 0){
            //require (_mintMultisign[amount]._firstSigner != msg.sender, "This user already sign this mint request");
            _mintMultisign[amount]._signs++;
            _mintMultisign[amount]._firstSigner = msg.sender;
        }else{
            require (_mintMultisign[amount]._firstSigner != msg.sender, "This user already sign this mint request");
            bytes memory mintToken = abi.encodeWithSignature("mint(uint256)", amount);
            (bool _success, bytes memory _returnData) = _tokenContract.call(mintToken);
            require(_success == true);
            _mintMultisign[amount]._signs = 0;
            _mintMultisign[amount]._firstSigner = address(0);
            return _success;
        }

        return false;       
    }

    modifier onlyAdmin() 
    {
        require(isAdmin(),
        "Function accessible only by an admin");
        _;
    }
    
    function isAdmin() public view returns(bool) 
    {
        return _admins[msg.sender];
    }

    function addAdmin(address _admin) onlyAdmin public returns (bool success){
        _admins[_admin] = true;
        _qntyAdmins++;

        return true;
    }

    function removeAdmin(address _admin) onlyAdmin public returns (bool success){
        _admins[_admin] = false;
       _qntyAdmins--;

        return true;
    }

    function setSellPrice(uint256 _sellPrice) onlyAdmin external {
        require(_sellPrice > 0, "Sell price should be a positive number");
        sellPrice = _sellPrice;
    }

    function setBuyPrice(uint256 _buyPrice) onlyAdmin external {
        require(_buyPrice > 0, "Buy price should be a positive number");
        buyPrice = _buyPrice;
    }

    function setMaxAmountToTransfer(uint256 maxAmount) onlyAdmin external {
        require(maxAmount > 0, "Max amount should be a positive number");
        maxAmountToTransfer = maxAmount;
    }

    function exchangeEther(uint256 tokensAmount) external payable {
        require(tokensAmount <= maxAmountToTransfer, "Amount to exchange should be less that the max amount to transfer setted");
        bytes memory transferTokens = abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), tokensAmount);
        (bool transferSuccess, bytes memory transferReturnData) = _tokenContract.call(transferTokens);
        require(transferSuccess == true, "Method transferFrom in Vault Contract fail.");
        if (transferSuccess) {
            uint256 amountToTransfer = tokensAmount * buyPrice;
            payable(msg.sender).transfer(amountToTransfer);
        }
    }

    receive() external payable {
        require (msg.value > 0, "Should deposit ethers to buy tokens");
        uint256 amountToTransfer = msg.value/sellPrice;
        bytes memory transferTokens = abi.encodeWithSignature("transfer(address,uint256)", msg.sender, amountToTransfer);
        (bool transferSuccess, bytes memory transferReturnData) = _tokenContract.call(transferTokens);
        require(transferSuccess == true, "Method transfer in Token Contract fail.");
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
            require (_withdraw._firstSigner != msg.sender, "This user already requested a withdraw");
        }
        
        uint256 percentage = _amount * 100 / address(this).balance;
        require(percentage <= _maxPercentageWithdraw, "The percentage to be withdrawn must not be greater than the maximum allowed");
        _withdraw._amount = _amount;
        _withdraw._signs++;
        _withdraw._firstSigner = msg.sender;
        if (_withdraw._signs == 2){
            _approvedWithdraws++;
            _withdrawHistory[_approvedWithdraws] = _amount;
            _withdraw._amount = 0;
            _withdraw._signs = 0;
            _withdraw._firstSigner = address(0);
        }
    }

    function withdraw() onlyAdmin public{
        require(_approvedWithdraws > 0, "There are no withdrawals approved yet");
        uint256 _adminWithdrawsQnty = _adminsWithdrawsQnty[msg.sender];
        require (_approvedWithdraws > _adminWithdrawsQnty, "This user has already made all pending withdrawals");
        _adminsWithdrawsQnty[msg.sender]++;
        uint256 amountToTransfer = _withdrawHistory[_adminWithdrawsQnty] / _qntyAdmins;
        payable(msg.sender).transfer(amountToTransfer);
    }

    function burn(uint256 _amount,address payable _address) public{
        uint256 _ethersToSend = _amount / (buyPrice * 50 / 100);
        require (address(this).balance >= _ethersToSend, "The amount to be transferred is greater than what can currently be supported");
        _address.transfer(_ethersToSend);
    }

    function setAPR(uint256 _value) external onlyAdmin returns (bool) {
        bytes memory _setAPR = abi.encodeWithSignature("setAPR(uint256)", _value);
        (bool _success, bytes memory _returnData) = _farmContract.call(_setAPR);
        
        return _success;
    }

    function transfer(address user, uint256 tokensAmount) external returns (bool) {
        require (msg.sender == _farmContract, "Only Farm Contract can call this method.");
        bytes memory transferTokens = abi.encodeWithSignature("transfer(address,uint256)",user, tokensAmount);
        (bool transferSuccess, bytes memory transferReturnData) = _tokenContract.call(transferTokens);
        require(transferSuccess == true, "Method transfer in Token Contract fail.");
        return transferSuccess;
    }
}