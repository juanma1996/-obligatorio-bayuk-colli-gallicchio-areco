//SPDX-License-Identifier:MIT
pragma solidity 0.8.14;
/
contract LogicBase {
	address public owner;
    address public proxyAddress;
    address public logicContract;
  	uint256 public result;
}

contract CalculadoraProxy is LogicBase {
  	address public owner;
    address public proxyAddress;
    address public logicContract;
  	uint256 public result;

    constructor() {
        owner = msg.sender;
    }

    function getBytecodeSum(uint256 _newValue1, uint256 _newValue2) external pure returns(bytes memory methodToCall){
        methodToCall = abi.encodeWithSignature("sumTwo(uint256,uint256)", _newValue1, _newValue2);
    }

    function getBytecodeWithdraw() external pure returns(bytes memory methodToCall){
        methodToCall = abi.encodeWithSignature("withdraw()");
    }
   
    function setLogicContract(address _newLogicContract) external {
        logicContract = _newLogicContract;
    }

    fallback() external payable {
        address _logicContract = logicContract;
        assembly {
            let methodToCall := mload(0x40)
            calldatacopy(methodToCall, 0, calldatasize())
            let resultOp := delegatecall(gas(), _logicContract, methodToCall, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(methodToCall, 0, size)
            switch resultOp
            case 0 { revert(methodToCall, size) }
            default { return(methodToCall, size) }
        }
    }
}

contract CalculadoraLogic is LogicBase {
  	address public owner;
    address public proxyAddress;
    address public logicContract;
  	uint256 public result;
  
  	modifier isOwner() {
  		require(msg.sender == owner, "You are not the owner");
        _;
    }
  
  	constructor() {
        owner = msg.sender;
    }

    function setOwner(address _newOwner) external virtual isOwner() {
        owner = _newOwner;
    }
  
  	function setProxyAddress(address _newProxy) external virtual isOwner() {
        proxyAddress = _newProxy;
    }
   
    function sumTwo(uint256 _one, uint256 _two) external payable virtual {
      	require(msg.sender == proxyAddress, "Not the proxy");
        require(msg.value >= 1 ether, "Paga papu");
        require(_one + _two > _two, "Overwflow");
        result = _one + _two;
    }
   
    function withdraw() external payable virtual isOwner() {
      	require(msg.sender == proxyAddress, "Not the proxy");
        payable(owner).transfer(address(this).balance);	
    }
}

// Withraw
// 0x3ccfd60b

// Sum 1 + 2
//0xb035513600000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002