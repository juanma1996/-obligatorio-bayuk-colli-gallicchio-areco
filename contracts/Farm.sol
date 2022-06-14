// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Farm {

    uint256 private totalStake;
    uint8 private APR;

    struct Stake{
        address userAddress; 
        uint256 amount;
        uint256 since;
    }

    struct Stakeholder{
        address userAddress;
        Stake[] userAddressStakes;
    }
    
    Stakeholder[] internal stakeholders;

    mapping(address => Stakeholder) private _stakeBalancesByAddress;
    mapping(address => uint256) private _stakeBalancesIndex;

    constructor(uint256  _total, uint8  _APRval){
        totalStake = _total;
        APR = _APRval;
    }

    function APRfunction() public view returns (uint8)
    {
        return APR;
    }

    function total() public view returns (uint256)
    {
        return totalStake;
    }

    //function balanceOf(address _owner) public view returns (uint256 balance)
    //{
    //    return _stakeBalances[_owner];
    //}

    //the index is the space in the array in which the users stakes are stored, when we have an address, the stake
    //index can be retrieved by using mapping _stakeBalancesIndex
    event StakeEvent(address indexed userAddress, uint256 amount, uint256 index, uint256 stakedSince);

    //first we have to add the stakeholder, this means creating a space in the stakeholders array
    function _addStakeholder(address newStakeholder) internal returns (uint256){
        stakeholders.push(); //create empty space
        uint256 indexIs = stakeholders.length - 1; //calculates the index number
        stakeholders[indexIs].userAddress = newStakeholder; //assigns the address to the index created
        _stakeBalancesIndex[newStakeholder]; //adds index to the stakeholder
        return indexIs;
    }

     //stake(uint256 _amount)
    function _stake(uint256 _amount) internal{
        require(_amount > 0, "Cannot stake zero");
        
        uint256 index = _stakeBalancesIndex[msg.sender];
        uint256 stakedSince = block.timestamp;

        if(index == 0){ //if its the first time this person is staking, we add them to the stakeholders collection
            index = _addStakeholder(msg.sender); //addStakeholders returns the index assigned to the person
        }

        stakeholders[index].userAddressStakes.push(Stake(msg.sender, _amount, stakedSince)); //pushing the new stake
        emit Stake(msg.sender, _amount, index,stakedSince);
    }

    //unstake(uint256 _amount)

    //withdrawYield()

    //getYield()

    //getStake()

    //getTotalStake()

    //getTotalYieldPaid()

    //getAPR()

    //setAPR(uint256 _value)

}