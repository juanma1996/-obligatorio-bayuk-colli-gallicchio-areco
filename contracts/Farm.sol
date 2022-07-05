// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

//TODO: make sure that before staking the user has the amount they want to stake (amount <= balance)
//After staking an x amount, we have to burn x amount from the users balance. 
//When unstaking, we have to make sure the unstaking amount is equal or more than the users staked balance. 

contract Farm {
    uint256 private _totalStake;
    uint256 private _totalYield;
    uint256 private _APR;
    address private _vaultContract;
    address private _tokenContract;
    address private _owner;

    struct Stake{
        uint256 amount;
        uint256 since;
        uint256 yield; //increases next time the user stakes, or when yield gets calculated
    }

    mapping(address => Stake) private _stakes;

    constructor(){
        _owner = msg.sender;
    }

    modifier onlyOwner() 
    {
        require(isOwner(),
        "Function accessible only by the owner");
        _;
    }

    function isOwner() public view returns(bool) 
    {
        return _owner == msg.sender;
    }

    function setTokenContract(address newAddress) onlyOwner external
    {
        require(newAddress != address(0), "ERC20: Token Contract Account zero address");
        _tokenContract = newAddress;
    }

    function setVaultContract(address newAddress) onlyOwner public {
        require(newAddress != address(0), "ERC20: Vault Contract Account zero address");
        _vaultContract = newAddress;
    }
    
    function stake(uint256 _amount) external{
        require(_amount > 0, "Cannot stake zero.");
        executeMethodTransferFromTokenContract(msg.sender, _vaultContract, _amount);
        uint256 newYield = calculateYield();
         updateYield(newYield);
        _stakes[msg.sender].amount += _amount;
       
        _totalStake += _amount;
    }

    function calculateYield() internal view returns (uint256){
        uint256 today = block.timestamp;
        uint256 diff = (today - _stakes[msg.sender].since) / 1 days; // / 60 / 60 / 24; //diff in days 
        uint256 aprCalculated = diff * _APR / 365; //APR is in 365 days
        uint256 amount = _stakes[msg.sender].amount;
        return (aprCalculated * amount);
    }

    function executeMethodTransferFromTokenContract(address from, address to, uint256 tokensAmount) internal returns (bool success){
        bytes memory methodCall = abi.encodeWithSignature("transferFrom(address, address, uint256)",from, to, tokensAmount);
        (bool _success, bytes memory _returnData) = _tokenContract.call(methodCall);
        require(_success == true);
        return _success;
    }

    function executeMethodTransferFromVault(address to, uint256 tokensAmount) internal returns (bool success){
        bytes memory methodCall = abi.encodeWithSignature("transfer(address, uint256)",to, tokensAmount);
        (bool _success, bytes memory _returnData) = _vaultContract.call(methodCall);
        require(_success == true);
        return _success;
    }

    function updateYield(uint256 newYield) internal {
        _stakes[msg.sender].yield += newYield;
        _stakes[msg.sender].since = block.timestamp;
    }


    function unstake(uint256 _amount) internal{
        require(_amount <= _stakes[msg.sender].amount, "Cannot unstake more than stake amount.");
        uint256 newYield = calculateYield();
        updateYield(newYield);
        _stakes[msg.sender].amount -= _amount;
        _totalStake -= _amount;
        executeMethodTransferFromVault(msg.sender, _amount);
    }

    function withdrawYield() external returns (uint256) {
        uint256 toReturn = getYield();
        _totalYield += toReturn;
        resetYield();

        return toReturn;
    }

    function resetYield() internal{
        _stakes[msg.sender].yield = 0;
    }

    function getYield() public returns (uint256) {
        uint256 newYield = calculateYield();
        updateYield(newYield);
        return _stakes[msg.sender].yield; 
    }

    function getStake() public view returns (uint256) {
       return _stakes[msg.sender].amount;
    }

    function getTotalStake() public view returns (uint256) {
        return _totalStake;
    }

    function getTotalYieldPaid() public view returns (uint256) {
        return _totalYield;
    }

    function getAPR() public view returns (uint256){
        return _APR;
    }

    function setAPR(uint256 _value) external returns (bool) {
        require(msg.sender == _vaultContract);
        _APR = _value;

        return true;
    }

}