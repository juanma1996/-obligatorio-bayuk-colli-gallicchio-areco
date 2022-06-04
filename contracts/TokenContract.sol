// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract TokenContract {

    uint256 constant public VERSION = 100;
    string private nameToken = "";
    string private symbolToken = "";
    uint8 private decimalsToken;
    uint256 private totalSupplyToken;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply)
    {
        nameToken = _name;
        symbolToken = _symbol;
        decimalsToken = _decimals;
        totalSupplyToken = _totalSupply;
    }

    function name() public view returns (string memory){
        return nameToken;
    }

    function symbol() public view returns (string memory)
    {
        return symbolToken;
    }

    function decimals() public view returns (uint8)
    {
        return decimalsToken;
    }

    function totalSupply() public view returns (uint256)
    {
        return totalSupplyToken;
    }

    function balanceOf(address _owner) public view returns (uint256 balance)
    {
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success)
    {
      require(_value <= _balances[msg.sender]);
  
      return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    {
        
    }

    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining)
    {
         return _allowances[_owner][_spender];
    }

   // event Transfer(address indexed _from, address indexed _to, uint256 _value)
   // {
      
   // }

   // event Approval(address indexed _owner, address indexed _spender, uint256 _value)
   // {

   // }

   

}