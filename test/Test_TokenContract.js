const { expect, use } = require("chai");
const { waffle } = require("hardhat");
const { deployContract, provider, solidity } = waffle;

const TokenContract= require('../artifacts/contracts/TokenContract.sol/TokenContract.json');

//use(solidity.waffleChai);

let token;
let mock;
const [wallet, walletTo, walletFrom] = provider.getWallets();

beforeEach(async () => {
  token = await deployContract(wallet,TokenContract,["Obli Token", "OTK", 8, 1000000]);

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

it("TotalSupply its OK", async () => {
  expect(await token.totalSupply()).to.equal(1000000);
});

it("Transfer y BalanceOf its OK", async () => {
     await token.transfer(walletTo.address, 10);
     expect(await token.balanceOf(walletTo.address)).to.equal(10);
});
  
it("Assigns initial balance", async () => {
    expect(await token.balanceOf(wallet.address)).to.equal(1000000);
})

it("Approve and Allowance methods its Oks", async () => {
    await token.approve(walletTo.address, 10) ;
    expect(await token.allowance(wallet.address, walletTo.address)).to.equal(10);
})


it("TransferFrom methods its Oks", async () => {
    await token.approve(wallet.address, 10) ;
    await token.transferFrom(wallet.address, walletTo.address,5);
    expect(await token.allowance(wallet.address, wallet.address)).to.equal(5);
})

it("TransferFrom methods Fail", async () => {
    await token.approve(wallet.address, 10) ;
    expect(await token.transferFrom(wallet.address, walletTo.address,25)).to.be.revertedWith("ERC20: transfer amount exceeds allowance");
})
  

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
