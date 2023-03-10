// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract TokenContract {

    uint256 constant public VERSION = 100;
    string private nameToken = "";
    string private symbolToken = "";
    uint8 private decimalsToken;
    uint256 private totalSupplyToken;
    address private vaultContract;
    address private _ownerAddress;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory _name, string memory _symbol, uint8 _decimals)
    {
        nameToken = _name;
        symbolToken = _symbol;
        decimalsToken = _decimals;
        _ownerAddress = msg.sender;
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

    function mint(uint256 amount) external {
        require(msg.sender != address(0), "ERC20: mint to the zero address");
        require(msg.sender == vaultContract, "ERC20: mint must be Vault Account");
        totalSupplyToken+=amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function executeMethodBurnFromVault(uint256 tokensAmount, address to) private{
         bytes memory methodCall = abi.encodeWithSignature("burn(uint256,address)", tokensAmount, to);
         (bool _success, bytes memory _returnData) = vaultContract.call(methodCall);
        require(_success == true, "Method Burn in Vault Contract fail.");
         if(_success == true){
           emit BurnFromVault(tokensAmount, to);
          }
    }

    function setAccountVault(address newAddress) onlyOwner external {
        require(newAddress != address(0), "ERC20: Vault Account zero address");
        vaultContract = newAddress;
    }

    function burn(uint256 amount) external {
        require(msg.sender != address(0), "ERC20: burn from the zero address");
        require(msg.sender != vaultContract, "ERC20: mint musn't be Vault Account");
        require(_balances[msg.sender] >= amount, "ERC20: burn amount exceeds balance");
        totalSupplyToken-=amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        executeMethodBurnFromVault(amount, msg.sender);
        emit Transfer(msg.sender, address(0), amount);
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success)
    {
        // We verify that the account calling the contract function is non-zero.
        require(msg.sender != address(0), "ERC20: approve from the zero address");
        // We verify that the origin account which will transfer tokens to another account is different from zero.
        require(_from != address(0), "ERC20: From Account is the zero address");
         // We verify that the destination account to which the tokens will be transferred is different from zero.
        require(_to != address(0), "ERC20: To Account is the zero address");
        // We verify that the account that calls the function has permission to transfer the indicated amount from the source account to another.
        require(_allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        uint256 currentAllowance = _allowances[_from][msg.sender];
        // Amount is subtracted
        _approve( _from, msg.sender, currentAllowance - _value);
        // The transfer is made from the source account (FROM) to the destination account (To)
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

    
    function approve(address _spender, uint256 _value) external returns (bool success)
    {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private 
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(_balances[owner] >= amount, "Approve amount exceeds owner balance");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining)
    {
         return _allowances[_owner][_spender];
    }

    modifier onlyOwner() 
    {
        require(isOwner(), "Function accessible only by the owner");
        _;
    }

    function isOwner() private view returns(bool) 
    {
        return _ownerAddress == msg.sender;
    }

    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event BurnFromVault(uint256 tokensAmount, address to);
    event SetTransferAccountFromVault(address transferAccount);
}