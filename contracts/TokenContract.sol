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
       _transfer(msg.sender, _to, _value);
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
        require(msg.sender != address(0), "ERC20: approve from the zero address");
        require(_from != address(0), "ERC20: approve to the zero address");
        require(_allowances[msg.sender][_from] >= _value, "ERC20: transfer amount exceeds allowance");
        uint256 currentAllowance = _allowances[msg.sender][_from];
        _approve(msg.sender, _from, currentAllowance - _value);
        _transfer(_from, _to, _value);
       return true;
    }

    function _transfer(address _from, address _to, uint256 _value) private{
        require(_from != address(0), "ERC20: Transfer to ZERO Address");
        require(_to != address(0), "ERC20: Transfer to ZERO Address");

        uint256 fromBalance = _balances[_from];
        require(_value <= fromBalance,"ERC20: transfer amount exceeds balance");

        _balances[_from] = _balances[_from] - _value;
        _balances[_to] = _balances[_to] + _value;

        //emit Transfer(from, to, amount);
        
    }

    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
       //emit Approval(owner, spender, amount);
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