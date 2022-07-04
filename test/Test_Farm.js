const { expect, use } = require("chai");
const { waffle } = require("hardhat");
const { deployContract, provider, solidity } = waffle;

const FarmContract= require('../artifacts/contracts/Farm.sol/Farm.json');
const VaultContract= require('../artifacts/contracts/Vault.sol/Vault.json');
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { deployMockContract } = require("ethereum-waffle");

let tokenFarm, vaultMockToken, vaultToken;
const [wallet, walletStake, walletFrom, vaultContract] = provider.getWallets();

beforeEach(async () => {
    tokenFarm = await deployContract(wallet,FarmContract);
    //vaultMockToken = await deployMockContract(wallet, VaultContract.abi);
  
    //vaultToken = await token.connect(vaultContract);
    //adminToken = await token.connect(wallet);
    //await adminToken.setAccountVault(vaultContract.address);
    //await vaultToken.mint(1000000000);
  });

  it("Stake Method and GetStake Return its OK", async () => {
    const newToken = await tokenFarm.connect(walletStake);
    await newToken.stake(10);
    expect(await newToken.getStake()).to.equal(10);
  });

  it("Stake Method Fail - Stake 0", async () => {
    const newToken =  tokenFarm.connect(walletStake);
    await expectRevert(newToken.stake(0),"Cannot stake zero.'");

    //await expect(newToken.burn(1)).to.be.revertedWith("ERC20: burn amount exceeds balance");
  });