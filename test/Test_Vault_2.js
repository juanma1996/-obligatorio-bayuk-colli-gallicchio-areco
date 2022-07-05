const { expect, use } = require("chai");
const { waffle } = require("hardhat");
const { deployContract, provider, solidity } = waffle;

const TokenContract = require("../artifacts/contracts/TokenContract.sol/TokenContract.json");
const VaultContract = require("../artifacts/contracts/Vault.sol/Vault.json");
const { BN, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");
const { deployMockContract } = require("ethereum-waffle");

describe("Token Contract", function () {
  let token, vaultMockToken, vaultToken;
  const [wallet, wallet2, walletFrom, vaultContract] = provider.getWallets();

  beforeEach(async () => {
    token = await deployContract(wallet, TokenContract, [
      "Obli Token",
      "OTK",
      8,
    ]);
    //vaultMockToken = await deployMockContract(wallet, VaultContract.abi);
    vaultMockToken = await deployContract(wallet, VaultContract);

    vaultToken = await token.connect(vaultContract);
    adminToken = await token.connect(wallet);
    await adminToken.setAccountVault(vaultContract.address);
    await vaultToken.mint(1000000000);
  });



  describe("ExchangeEther", function () {
    it("ExchangeEther its OK", async () => {

      await vaultMockToken.setMaxAmountToTransfer(10);
      await vaultMockToken.setBuyPrice(1);

      const tokenUser = await vaultMockToken.connect(wallet2);
      const tokenUser3 = await token.connect(wallet2);
      const tokenUser2 = await token.connect(vaultContract);
      await vaultMockToken.setTransferAccount(token.address);

      tokenUser2.transfer(tokenUser.address,2);

      tokenUser3.approve(vaultContract.address, 2);

      tokenUser.exchangeEther(2);

    });
  });


});
