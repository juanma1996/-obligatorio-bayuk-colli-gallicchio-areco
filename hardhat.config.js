require('dotenv').config();
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-waffle");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: "0.8.14",
  networks: {
      ganache: {
      chainId: 1337,
      timeout: 20000,
      gasPrice: 8000000000,
      gas: "auto",
      name: "Ganache",
      url: process.env.GANACHE_URL,
      from: process.env.GANACHE_ACCOUNT,
      accounts: [process.env.GANACHE_PRIVATE_KEY, process.env.GANACHE_PRIVATE_KEY2]

    },
    rinkeby: {
      chainId: 4,
      timeout: 20000,
      gasPrice: 8000000000,
      gas: "auto",
      name: "Rinkeby",
      url: process.env.RINKEBY_ACCESSPOINT_URL,
      from: process.env.RINKEBY_ACCOUNT,
      accounts: [process.env.RINKEBY_PRIVATE_KEY, process.env.RINKEBY_PRIVATE_KEY2]

    },
    hardhat:{
      chainId: 31337,
      name: "hardhat",
      gas: "auto",
      gasPrice: "auto"
    }
  }
};
