/**
* @type import('hardhat/config').HardhatUserConfig
*/

require('dotenv').config();
require("@nomiclabs/hardhat-ethers");


module.exports = {
   solidity: "0.8.17",
   settings: {
    optimizer: {
      enabled: true,
      runs: 1000
    }
  },

   networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: process.env.STAGING_INFURA_URL,
      accounts: [`0x${process.env.STAGING_PRIVATE_KEY}`],
      gas: 2100000,
      gasPrice: 8000000000,
      allowUnlimitedContractSize: true
    },
  },
}