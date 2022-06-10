// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract TokenContract {

    uint256 constant public VERSION = 100;
    string private nameToken = "";
    string private symbolToken = "";
    uint8 private decimalsToken;
    uint256 private totalSupplyToken;
    address private vaultAccount;

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

    function mint(uint256 amount) public {
        require(msg.sender != address(0), "ERC20: mint to the zero address");
        require(msg.sender == vaultAccount, "ERC20: mint must be Vault Account");
        totalSupplyToken+=amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;
        emit Transfer(address(0), msg.sender, amount);
    }

     function setAccountVault() public {
         require(msg.sender != address(0), "ERC20: Vault Account zero address");
        vaultAccount = msg.sender;
        
    }

    function burn(uint256 amount) public {
        require(msg.sender != address(0), "ERC20: burn from the zero address");
        require(msg.sender != vaultAccount, "ERC20: mint musn't be Vault Account");
        totalSupplyToken-=amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    {
        // Verificamos que la cuenta que llama a la función del contrato es diferente de cero.
        require(msg.sender != address(0), "ERC20: approve from the zero address");
        // Verificamos que la cuenta origen la cual transferirá tokens a otra cuenta es diferente de cero.
        require(_from != address(0), "ERC20: From Account is the zero address");
         // Verificamos que la cuenta destino a la cual se transferirá tokens es diferente de cero.
        require(_to != address(0), "ERC20: To Account is the zero address");
        // Verificamos que la cuenta que llama a la función tiene permiso para transferir desde la cuenta de origen a otra el monto indicado.
        require(_allowances[msg.sender][_from] >= _value, "ERC20: transfer amount exceeds allowance");
        uint256 currentAllowance = _allowances[msg.sender][_from];
        // Se da de baja la cantidad "permitida"
        _approve(msg.sender, _from, currentAllowance - _value);
        // Se hace la transferencia desde la cuenta origen (FROM) a la cuenta destino (To)
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

        emit Transfer(_from, _to, _value);
        
    }

    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private 
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining)
    {
         return _allowances[_owner][_spender];
    }

    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    

}