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
    
    function _stake(uint256 _amount) internal{
        require(_amount > 0, "Cannot stake zero.");
        executeMethodTransferFromTokenContract(_amount,msg.sender);
        _stakes[msg.sender].amount += _amount;
        _stakes[msg.sender].since = block.timestamp;
        _stakes[msg.sender].yield = updateYield();
        _totalStake += _amount;
    }

    function executeMethodTransferFromTokenContract(uint256 tokensAmount, address to) public returns (bool success){
        bytes memory methodCall = abi.encodeWithSignature("transferFrom(address, uint256)", to, tokensAmount);
        (bool _success, bytes memory _returnData) = _tokenContract.call(methodCall);

        return _success;
    }

    function updateYield() internal returns (uint256){
        uint256 today = block.timestamp;
        uint256 diff = (today - _stakes[msg.sender].since) / 1 days; // / 60 / 60 / 24; //diff in days 
        uint256 updatedYield = diff * _APR / 365; //APR is in 365 days
        _stakes[msg.sender].yield = updatedYield;
        _stakes[msg.sender].since = today; //as yield is not up to date, we had to calculate yield, to not calculate it twice next time we are staking or withdrawing we update "since"

        return updatedYield;
    }

    function unstake(uint256 _amount) internal{
        require(_amount <= _stakes[msg.sender].amount, "Cannot unstake more than stake amount.");
        updateYield(); 
        _stakes[msg.sender].amount -= _amount;
        _totalStake -= _amount;
        executeMethodMintVaultContract(_amount);
    }

    function withdrawYield() external returns (uint256) {
        updateYield(); //this is because yield gets calculated the next stake a person makes, so its not up to date now
        uint256 toReturn = getYield();
        _totalYield += toReturn;
        resetYield();
        executeMethodMintVaultContract(toReturn);

        return toReturn;
    }

    function executeMethodMintVaultContract(uint256 amountToMint) public returns (bool success) {
        bytes memory mintToken = abi.encodeWithSignature("mint(uint256)", amountToMint);
        (bool _success, bytes memory _returnData) = _vaultContract.call(mintToken);

        return _success;
    }

    function resetYield() internal{
        _stakes[msg.sender].yield = 0;
    }

    function getYield() public returns (uint256) {
        updateYield();

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

    function setAPR(uint256 _value) external returns (bool) { //PRE: Setter is admin
        require(msg.sender == _vaultContract);
        _APR = _value;

        return true;
    }

}