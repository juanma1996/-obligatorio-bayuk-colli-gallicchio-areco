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

it("TransferFrom method its Oks", async () => {
  
    const newToken = await token.connect(walletFrom);
    await vaultToken.approve(walletFrom.address, 10) ;
    
    await newToken.transferFrom(vaultContract.address, walletTo.address,5);
    expect(await token.allowance(vaultContract.address, walletFrom.address)).to.equal(5);
})

it("Burn method its Oks", async () => {
  await vaultMockToken.mock.burn;

  await vaultToken.transfer(walletTo.address, 10);
  const newToken = await token.connect(walletTo);
  await newToken.burn(10);
  expect(await token.balanceOf(walletTo.address)).to.equal(0);
})

it("TransferFrom Should fail for Amount exceeds allowed", async function () {
  const newToken = await token.connect(walletFrom);
  await vaultToken.approve(walletFrom.address, 10) ;
  
  await expect(newToken.transferFrom(vaultContract.address, walletTo.address,25)).to.be.revertedWith("ERC20: transfer amount exceeds allowance");
});


it("Mint fail because the caller not is Vault Account", async () => {
    const newToken = await token.connect(walletFrom);
    await expect(newToken.mint(1000000000)).to.be.revertedWith("ERC20: mint must be Vault Account");
})


it("Burn fail because the caller is Vault Account", async () => {
  await vaultMockToken.mock.burn;
  await expect(vaultToken.burn(10)).to.be.revertedWith("ERC20: mint musn't be Vault Account");
  
})

it("Burn methods fail for Mount to burn Exceeds balance", async () => {
  const newToken = await token.connect(walletTo);
  await expect(newToken.burn(1)).to.be.revertedWith("ERC20: burn amount exceeds balance");
  
})

it("Transfer methods Fail", async () => {
    const newToken = await token.connect(walletFrom);
    await expectRevert(token.transfer(walletTo.address,25),"ERC20: transfer amount exceeds balance'");
})

it("AddAdmin fail because calle is not admin", async () => {
  const newToken = await token.connect(walletTo);
  await expect(newToken.addAdmin(newToken.address)).to.be.revertedWith("Function accessible only by an admin");
})

it("RemoveAdmin fail because calle is not admin", async () => {
  const newToken = await token.connect(walletTo);
  await expect(newToken.removeAdmin(wallet.address)).to.be.revertedWith("Function accessible only by an admin");
})

it("AddAdmin method its Oks", async () => {
  await expect(token.addAdmin(walletTo.address));
})