// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

//TODO: make sure that before staking the user has the amount they want to stake (amount <= balance)
//After staking an x amount, we have to burn x amount from the users balance. 
//When unstaking, we have to make sure the unstaking amount is equal or more than the users staked balance. 

contract Farm {
    uint256 private _totalStake;
    uint256 private _totalYield;
    uint256 private _APR;
    address private _vaultContract;
    address private _tokenContract;

    struct Stake{
        uint256 amount;
        uint256 since;
        uint256 yield; //increases next time the user stakes, or when yield gets calculated
    }

    mapping(address => Stake) private _stakes;

    constructor(uint256  _total, uint256 _totalY){
        _totalStake = _total;
        _totalYield = _totalY;
    }

    function setVaultContract() external
    {
         _vaultContract = msg.sender;
    }

    function setTokenContract() external
    {
         _tokenContract = msg.sender;
    }

    function setAPRfunction() public view returns (uint256)
    {
        require(msg.sender == _vaultContract);
        return _APR;
    }

     //stake(uint256 _amount)
    function _stake(uint256 _amount) internal{
        require(_amount > 0, "Cannot stake zero.");

        //TODO: executeMethodTransferFromTokenContract(_amount,msg.sender);

        _stakes[msg.sender].amount += _amount;
        _stakes[msg.sender].since = block.timestamp;
        _stakes[msg.sender].yield = updateYield();

        _totalStake += _amount;
    }

    //function executeMethodTransferFromTokenContract(uint256 tokensAmount, address to) private{
        //bytes memory methodCall = abi.encodeWithSignature("transferFrom(address, uint256)", to, tokensAmount);
        //(bool _success, bytes memory _returnData) = _tokenContract.call(methodCall);
    //}

    function updateYield() internal returns (uint256){
        uint256 today = block.timestamp;
        uint256 diff = (today - _stakes[msg.sender].since) / 1 days; // / 60 / 60 / 24; //diff in days 
        uint256 updatedYield = diff * _APR / 365; //APR is in 365 days

        _stakes[msg.sender].yield = updatedYield;
        _stakes[msg.sender].since = today; //as yield is not up to date, we had to calculate yield, to not calculate it twice next time we are staking or withdrawing we update "since"

        return updatedYield;
    }

    //unstake(uint256 _amount)
    function unstake(uint256 _amount) internal{
        require(_amount <= _stakes[msg.sender].amount, "Cannot unstake more than stake amount.");

        updateYield(); 
        
        _stakes[msg.sender].amount -= _amount;

        _totalStake -= _amount;

        //TODO: Mint
    }

    //withdrawYield()
    function withdrawYield() external returns (uint256) {
        updateYield(); //this is because yield gets calculated the next stake a person makes, so its not up to date now
        uint256 toReturn = getYield();
        _totalYield += toReturn;
        resetYield();
        //TODO: Mint
        return toReturn;
    }

    function resetYield() internal{
        _stakes[msg.sender].yield = 0;
    }

    //getYield() 
    function getYield() public returns (uint256) {
        updateYield();
        return _stakes[msg.sender].yield; 
    }

    //getStake()
    function getStake() public view returns (uint256) {
       return _stakes[msg.sender].amount;
    }

    //getTotalStake()
    function getTotalStake() public view returns (uint256) {
        return _totalStake;
    }

    //getTotalYieldPaid()
    function getTotalYieldPaid() public view returns (uint256) {
        return _totalYield;
    }

    //getAPR()
    function getAPR() public view returns (uint256){
        return _APR;
    }

    //setAPR(uint256 _value)
    function setAPR(uint256 _value) external returns (bool) { //PRE: Setter is admin
        require(msg.sender == _vaultContract);
        _APR = _value;
        return true;
    }

}