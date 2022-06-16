// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

//TODO: make sure that before staking the user has the amount they want to stake (amount <= balance)
//After staking an x amount, we have to burn x amount from the users balance. 
//When unstaking, we have to make sure the unstaking amount is equal or more than the users staked balance. 

contract Farm {
    uint256 private totalStake;
    uint256 private APR;
    address private _vaultContract;

    struct Stake{
        uint256 amount;
        uint256 since;
        uint256 yield; //increases next time the user stakes
    }

    mapping(address => Stake) private _stakes;

    constructor(uint256  _total, uint8  _APRval){
        totalStake = _total;
        APR = _APRval;
    }

    function setVaultContract() external
    {
         _vaultContract = msg.sender;
    }

    function setAPRfunction() public view returns (uint256)
    {
        require(msg.sender == _vaultContract);
        return APR;
    }

     //stake(uint256 _amount)
    function _stake(uint256 _amount) internal{
        require(_amount > 0, "Cannot stake zero.");

        _stakes[msg.sender].amount += _amount;
        _stakes[msg.sender].since = block.timestamp;
        _stakes[msg.sender].yield = calculateYield();

        totalStake += _amount;

        // emit StakeEvent(msg.sender, _amount, index,stakedSince);
    }

    function calculateYield() internal view returns (uint256){
        uint256 today = block.timestamp;
        uint256 diff = (today - _stakes[msg.sender].since) / 1 days; // / 60 / 60 / 24; //diff in days 
        uint256 updatedYield = diff * APR / 365; //APR is in 365 days

        return updatedYield;
    }

    //unstake(uint256 _amount)
    function unstake(uint256 _amount) internal{
         require(_amount <= _stakes[msg.sender].amount, "Cannot stake more than stake amount.");

        _stakes[msg.sender].amount -= _amount;
        //_stakes[msg.sender].since = block.timestamp; //TODO: WHAT HAPPENS TO 'SINCE' WHEN UNSTAKING ?

        totalStake -= _amount;
    }

    //withdrawYield()
    function withdrawYield() public returns (uint256) {
        calculateYield(); //because yield gets calculated the next stake a person makes, so its not up to date now
        _stakes[msg.sender].since = block.timestamp; //as yield is not up to date, we had to calculate yield, to not calculate it twice next time we are staking or withdrowingwe update "since"
        uint256 toReturn = getYield();
        resetYield();
        return toReturn;
    }

    function resetYield() internal{
        _stakes[msg.sender].yield = 0;
    }

    //getYield() 
    function getYield() public view returns (uint256) {
       return _stakes[msg.sender].yield; 
    }


    //getStake()
    function getStake() public view returns (uint256) {
       return totalStake; 
    }

    // function getBalance(address _owner) public view returns (uint256 balance)
    // {
    //     // return _stakeBalancesByAddress[_owner].amount;
    // }

    //getTotalStake()
    function getTotalStake() public view returns (uint256) {
        return totalStake;
    }

    //getTotalYieldPaid()

    //getAPR()
    function getAPR() public view returns (uint256){
        return APR;
    }

    //setAPR(uint256 _value)
    function setAPR(uint256 _value) external returns (bool) { //PRE: Setter is admin
        require(msg.sender == _vaultContract);
        APR = _value;
        return true;
    }

}