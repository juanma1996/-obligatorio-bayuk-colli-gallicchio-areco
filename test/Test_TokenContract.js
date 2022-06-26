const { expect, use } = require("chai");
const { waffle } = require("hardhat");
const { deployContract, provider, solidity } = waffle;

const TokenContract= require('../artifacts/contracts/TokenContract.sol/TokenContract.json');
const VaultContract= require('../artifacts/contracts/Vault.sol/Vault.json');
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { deployMockContract } = require("ethereum-waffle");

//use(solidity.waffleChai);

let token, vaultMockToken, vaultToken;
const [wallet, walletTo, walletFrom, vaultContract] = provider.getWallets();

beforeEach(async () => {
  token = await deployContract(wallet,TokenContract,["Obli Token", "OTK", 8]);
  vaultMockToken = await deployMockContract(wallet, VaultContract.abi);

  vaultToken = await token.connect(vaultContract);
  await vaultToken.setAccountVault();
  await vaultToken.mint(1000000000);
});

it("Name Token Return its OK", async () => {
  expect(await token.name()).to.equal("Obli Token");
});

it("Symbol Token Return its OK", async () => {
  expect(await token.symbol()).to.equal("OTK");
});

it("Decimals of Token its OK", async () => {
  expect(await token.decimals()).to.equal(8);
});

it("Assigns initial balance", async () => {
  expect(await token.balanceOf(vaultContract.address)).to.equal(1000000000);
})

it("Transfer y BalanceOf its OK", async () => {
  await vaultToken.transfer(walletTo.address, 10);
  expect(await token.balanceOf(walletTo.address)).to.equal(10);
});
  

it("Approve and Allowance methods its Oks", async () => {
    const newToken = await token.connect(vaultContract);
    await newToken.approve(walletTo.address, 10) ;
    expect(await token.allowance(vaultContract.address, walletTo.address)).to.equal(10);
})

it("TransferFrom methods its Oks", async () => {
  
    const newToken = await token.connect(walletFrom);
    await vaultToken.approve(walletFrom.address, 10) ;
    
    await newToken.transferFrom(vaultContract.address, walletTo.address,5);
    expect(await token.allowance(vaultContract.address, walletFrom.address)).to.equal(5);
})

it("Burn methods its Oks", async () => {
  await vaultMockToken.mock.burn;

  await vaultToken.transfer(walletTo.address, 10);
  const newToken = await token.connect(walletTo);
  await newToken.burn(10);
  expect(await token.balanceOf(walletTo.address)).to.equal(0);
})

//it("TransferFrom methods Fail", async () => {
  //  await token.approve(wallet.address, 10) ;
 //   await expectRevert(token.transferFrom(wallet.address, walletTo.address,25),"VM Exception while processing transaction: reverted with reason string 'ERC20: transfer amount exceeds allowance'");
//})
  

//const { expect, use } = require("chai");
//const { waffle } = require("hardhat");
//const { deployContract, provider, solidity} = waffle;

//use(solidity.waffleChai);

//const TokenContract = require("../artifacts/contracts/TokenContract.sol/TokenContract.json");

//describe("TokenContract") , function() {

  //  it("Should return then name of the Token indicate in the Constructor of the Contract.", async function(){
        //Arrange
    //    let tokenContract;
      //  const [ wallet, walletTo ] = provider.getWallets();
        //tokenContract = await deployContract(wallet, TokenContract, ["Obli Token", "OTK", 8, 1000000] );
        
        // Act
       // const response = await tokenContract.name();

        //Assert 

        //expect(response).to.equal("Obli Token");
    //});
//}
