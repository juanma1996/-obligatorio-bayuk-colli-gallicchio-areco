const { expect, use } = require("chai");
const { waffle } = require("hardhat");
const { deployContract, provider, solidity } = waffle;

const TokenContractProxy= require('../artifacts/contracts/TokenContractProxy.sol/TokenContractProxy.json');
const TokenContract= require('../artifacts/contracts/TokenContract.sol/TokenContract.json');
const VaultContract= require('../artifacts/contracts/Vault.sol/Vault.json');
const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { deployMockContract } = require("ethereum-waffle");

//use(solidity.waffleChai);

let token, vaultMockToken, vaultToken;
const [wallet, walletProxy, walletTo, walletFrom, vaultContract] = provider.getWallets();

beforeEach(async () => {
  tokenProxy = await deployContract(walletProxy,TokenContractProxy);
  token = await deployContract(wallet,TokenContract,["Obli Token", "OTK", 8]);
  vaultMockToken = await deployMockContract(wallet, VaultContract.abi);
  await tokenProxy.setBaseContract(wallet.address);
  
  vaultToken = await token.connect(vaultContract);
  await vaultToken.setAccountVault();
  await vaultToken.mint(1000000000);
});



it("Assigns initial balance", async () => {
    expect(await tokenProxy.balanceOf(vaultContract.address)).to.equal(1000000000);
  })

