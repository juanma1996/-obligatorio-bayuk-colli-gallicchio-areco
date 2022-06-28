const { expect } = require("chai");

describe("Token contract", function () {

  let Vault;
  let hardhatVault;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    Vault = await ethers.getContractFactory("Vault");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    hardhatVault = await Vault.deploy();
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
      await expect(
        hardhatVault.setBuyPrice(zeroBuyPrice)
      ).to.be.revertedWith("Buy price should be a positive number");

      // Buy price shouldn't have changed.
      expect(await hardhatVault.buyPrice()).to.equal(
        expectedBuyPrice
      );
    });

    it("Should fail if not admin", async function () {
        const expectedBuyPrice = 50;
        await hardhatVault.setBuyPrice(expectedBuyPrice);
        await expect(
          hardhatVault.connect(addr1).setBuyPrice(10)
        ).to.be.revertedWith("Set Buy price should be accesed by administrator");
  
        // Buy price shouldn't have changed.
        expect(await hardhatVault.buyPrice()).to.equal(
          expectedBuyPrice
        );
    });
  });
});