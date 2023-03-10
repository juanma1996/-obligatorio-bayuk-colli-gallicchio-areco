const { use, expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const { deployMockContract } = require("@ethereum-waffle/mock-contract");
const { MockProvider } = require("@ethereum-waffle/provider");
const { waffleChai } = require("@ethereum-waffle/chai");
const TokenContractFile = require("../bin/contracts/TokenContract");
const provider = waffle.provider;
use(waffleChai);
describe("Vault contract", function () {
  let Vault;
  let TokenContract;
  let hardhatVault;
  let hardhatTokenContract;
  let hardhatFarmContract;
  let mockTokenContract;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    const [sender, receiver] = new MockProvider().getWallets();
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    Vault = await ethers.getContractFactory("Vault");
    TokenContract = await ethers.getContractFactory("TokenContract");
    Farm = await ethers.getContractFactory("Farm");
    mockTokenContract = await deployMockContract(addr1, TokenContractFile.abi);

    hardhatVault = await Vault.deploy();
    hardhatTokenContract = await TokenContract.deploy("name", "symbol", 1);
    hardhatFarmContract = await Farm.deploy();
  });

  describe("Deployment", function () {
    it("Should set admin", async function () {
      expect(await hardhatVault.isAdmin()).to.equal(true);
    });
  });

  describe("Getters & Setters", function () {
    it("Should set/get buyPrice", async function () {
      const expectedBuyPrice = 50;
      await hardhatVault.setBuyPrice(expectedBuyPrice);
      const actualBuyPrice = await hardhatVault.buyPrice();
      expect(actualBuyPrice).to.equal(expectedBuyPrice);
    });

    it("Should fail if buyPrice <= 0", async function () {
      const expectedBuyPrice = 50;
      const zeroBuyPrice = 0;
      await hardhatVault.setBuyPrice(expectedBuyPrice);
      await expect(hardhatVault.setBuyPrice(zeroBuyPrice)).to.be.revertedWith(
        "Buy price should be a positive number"
      );

      // Buy price shouldn't have changed.
      expect(await hardhatVault.buyPrice()).to.equal(expectedBuyPrice);
    });

    it("Should fail if not admin set buyPrice", async function () {
      const expectedBuyPrice = 50;
      await hardhatVault.setBuyPrice(expectedBuyPrice);
      await expect(
        hardhatVault.connect(addr1).setBuyPrice(10)
      ).to.be.revertedWith("Function accessible only by an admin");

      // Buy price shouldn't have changed.
      expect(await hardhatVault.buyPrice()).to.equal(expectedBuyPrice);
    });

    it("Should set/get sellPrice", async function () {
      const expectedSellPrice = 50;
      await hardhatVault.setSellPrice(expectedSellPrice);
      const actualSellPrice = await hardhatVault.sellPrice();
      expect(actualSellPrice).to.equal(expectedSellPrice);
    });

    it("Should fail if sellPrice <= 0", async function () {
      const expectedSellPrice = 50;
      const zeroSellPrice = 0;
      await hardhatVault.setSellPrice(expectedSellPrice);
      await expect(hardhatVault.setSellPrice(zeroSellPrice)).to.be.revertedWith(
        "Sell price should be a positive number"
      );

      // Sell price shouldn't have changed.
      expect(await hardhatVault.sellPrice()).to.equal(expectedSellPrice);
    });

    it("Should fail if not admin set sellPrice", async function () {
      const expectedSellPrice = 50;
      await hardhatVault.setSellPrice(expectedSellPrice);
      await expect(
        hardhatVault.connect(addr1).setSellPrice(10)
      ).to.be.revertedWith("Function accessible only by an admin");

      // Sell price shouldn't have changed.
      expect(await hardhatVault.sellPrice()).to.equal(expectedSellPrice);
    });

    it("Should set/get maxAmountToTransfer", async function () {
      const expectedMaxAmountToTransfer = 50;
      await hardhatVault.setMaxAmountToTransfer(expectedMaxAmountToTransfer);
      const actualMaxAmountToTransfer =
        await hardhatVault.maxAmountToTransfer();
      expect(actualMaxAmountToTransfer).to.equal(expectedMaxAmountToTransfer);
    });

    it("Should fail if maxAmountToTransfer <= 0", async function () {
      const expectedMaxAmountToTransfer = 50;
      const zeroMaxAmountToTransfer = 0;
      await hardhatVault.setMaxAmountToTransfer(expectedMaxAmountToTransfer);
      await expect(
        hardhatVault.setMaxAmountToTransfer(zeroMaxAmountToTransfer)
      ).to.be.revertedWith("Max amount should be a positive number");

      // Max amount shouldn't have changed.
      expect(await hardhatVault.maxAmountToTransfer()).to.equal(
        expectedMaxAmountToTransfer
      );
    });

    it("Should fail if not admin set maxAmountToTransfer", async function () {
      const expectedMaxAmountToTransfer = 50;
      await hardhatVault.setMaxAmountToTransfer(expectedMaxAmountToTransfer);
      await expect(
        hardhatVault.connect(addr1).setMaxAmountToTransfer(10)
      ).to.be.revertedWith("Function accessible only by an admin");

      // Max amount shouldn't have changed.
      expect(await hardhatVault.maxAmountToTransfer()).to.equal(
        expectedMaxAmountToTransfer
      );
    });
  });

  
});
