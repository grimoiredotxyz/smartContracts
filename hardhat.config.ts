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
    },
    mumbai: {
      chainId: 1337,
      url: process.env.STAGING_INFURA_URL,
      accounts: [`0x${process.env.STAGING_PRIVATE_KEY}`],
      gas: 2100000,
      gasPrice: 8000000000,
      allowUnlimitedContractSize: true
    },
    goerli: {
      chainId: 420,
      url: process.env.API_URL,
      accounts: [`0x${process.env.STAGING_PRIVATE_KEY}`]
   },
   hyperspace: {
    chainId: 3141,
    url: "https://rpc.ankr.com/filecoin_testnet	",
    accounts: [`0x${process.env.STAGING_PRIVATE_KEY}`],

},
chiado: {
  chainId: 10200,
  url: 'https://rpc.chiadochain.net',
  gasPrice: 1000000000,
  accounts: [`0x${process.env.STAGING_PRIVATE_KEY}`],
  
},
scroll_testnet: {
  chainId: 534353,
  url: 'https://alpha-rpc.scroll.io/l2',
  accounts: [`0x${process.env.STAGING_PRIVATE_KEY}`]
}
},

}