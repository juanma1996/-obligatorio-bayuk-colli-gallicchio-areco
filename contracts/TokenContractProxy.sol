// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract TokenContractProxy {

    uint256 constant public VERSION = 100;
    string private nameToken = "";
    string private symbolToken = "";
    uint8 private decimalsToken;
    uint256 private totalSupplyToken;
    address private vaultContract;

    mapping(address => bool) private _admins;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private baseContract;

   // constructor(string memory _name, string memory _symbol, uint8 _decimals)
    //{
      //  bytes memory methodCall = abi.encodeWithSignature("constructor(string memory,string memory,uint8)",_name,_symbol,_decimals);
        //(bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        //if(_success == true){
           //emit SetTransferAccountFromVault(transferAccount);
        //}
    //}

    constructor()
    {}

    function name() public returns (string memory){
        bytes memory methodCall = abi.encodeWithSignature("name()");
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
            return string(_returnData);
        }
    }

    function symbol() public returns (string memory)
    {
        bytes memory methodCall = abi.encodeWithSignature("symbol()");
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
            return string(_returnData);
        }
    }

    function decimals() public returns (uint8)
    {
        bytes memory methodCall = abi.encodeWithSignature("decimals()");
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
            return abi.decode(_returnData, (uint8));
        }
    }

    function totalSupply() public returns (uint256)
    {
        bytes memory methodCall = abi.encodeWithSignature("totalSupply()");
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
             return abi.decode(_returnData, (uint256));
        }
    }

    function balanceOf(address _owner) public returns (uint256 balance)
    {
        bytes memory methodCall = abi.encodeWithSignature("balanceOf(address)",_owner);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
            return abi.decode(_returnData, (uint256));
        }
    }

    function transfer(address _to, uint256 _value) public returns (bool success)
    {
       bytes memory methodCall = abi.encodeWithSignature("transfer(address,uint256)",_to,_value);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
            return abi.decode(_returnData, (bool));
        }
    }

    function mint(uint256 amount) external {
        bytes memory methodCall = abi.encodeWithSignature("mint(uint256)",amount);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
            //return _returnData;
        }
    }

    function setAccountVault() external {
         bytes memory methodCall = abi.encodeWithSignature("setAccountVault()");
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
            //return _returnData;
        }
    }

    function burn(uint256 amount) external {
        bytes memory methodCall = abi.encodeWithSignature("burn(uint256)", amount);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
            //return _returnData;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success)
    {
      bytes memory methodCall = abi.encodeWithSignature("transferFrom(address,address,uint256)",_from,_to,_value);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
           return abi.decode(_returnData, (bool));
        }
    }

    function approve(address _spender, uint256 _value) external returns (bool success)
    {
        bytes memory methodCall = abi.encodeWithSignature("approve(address,uint256)",_spender,_value);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
           return abi.decode(_returnData, (bool));
        }
    }

    function allowance(address _owner, address _spender) external returns (uint256 remaining)
    {
        bytes memory methodCall = abi.encodeWithSignature("allowance(address,address)",_owner,_spender);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
             return abi.decode(_returnData, (uint256));
        }
    }

    function addAdmin(address _admin) public returns (bool success){
        bytes memory methodCall = abi.encodeWithSignature("addAdmin(address)",_admin);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
             return abi.decode(_returnData, (bool));
        }
    }

    function removeAdmin(address _admin) public returns (bool success){
        bytes memory methodCall = abi.encodeWithSignature("removeAdmin(address)",_admin);
        (bool _success, bytes memory _returnData) = baseContract.delegatecall(methodCall);
        if(_success == true){
             return abi.decode(_returnData, (bool));
        }
    }

    function setBaseContract(address baseAddress) public {
        baseContract = baseAddress;
    }
}