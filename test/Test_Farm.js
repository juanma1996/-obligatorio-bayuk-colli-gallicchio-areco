const { expect, use } = require("chai");
const { waffle } = require("hardhat");
const { deployContract, provider, solidity } = waffle;

const FarmContract = require("../artifacts/contracts/Farm.sol/Farm.json");
const VaultContract = require("../artifacts/contracts/Vault.sol/Vault.json");
const { BN, expectEvent, expectRevert } = require("@openzeppelin/test-helpers");
const { deployMockContract } = require("ethereum-waffle");

describe("Farm Contract", function () {
  let tokenFarm, tokenFarm2, tokenFarm3;
  const [wallet, walletStake, wallet2, wallet3] = provider.getWallets();

  beforeEach(async () => {
    tokenFarm = await deployContract(wallet, FarmContract);
    tokenFarm2 = await tokenFarm.connect(wallet2);
    await tokenFarm2.stake(10);

    tokenFarm3 = await tokenFarm.connect(wallet3);
  });

  describe("Stake", function () {
    it("Stake Method and GetStake Return its OK", async () => {
      const newToken = await tokenFarm.connect(walletStake);
      await newToken.stake(10);
      expect(await newToken.getStake()).to.equal(10);
    });

    it("Stake Method Fail - Stake 0", async () => {
      const newToken = tokenFarm.connect(walletStake);
      await expectRevert(newToken.stake(0), "Cannot stake zero.'");
    });
  });

  describe("Unstake", function () {
    it("Unstake Method and GetStake Return its OK", async () => {
      await tokenFarm2.unstake(5);
      expect(await tokenFarm2.getStake()).to.equal(5);
    });
  });

  describe("Get total stake", function () {
    it("GetTotalStake Method its OK", async () => {
      await tokenFarm3.stake(10);
      expect(await tokenFarm.getTotalStake()).to.equal(20);
    });
  });

  it("SetVaultContract Method, setAPR Return its OK", async () => {
    await tokenFarm.setVaultContract(wallet3.address);
    tokenFarm3.setAPR(5);
  });
});
