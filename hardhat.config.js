require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-contract-sizer");
require("hardhat-gas-reporter");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-abi-exporter");
require("solidity-docgen");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    hardhat: {
      forking: {
        url: process.env.ALCHEMY_URL,
        blockNumber: 15000000,
      },
    },
    dashboard: {
      url: "http://localhost:20412/rpc",
    },
  },
  gasReporter: {
    enabled: true,
    coinmarketcap: `${process.env.CMC_API_KEY}`,
    currency: "EUR",
    gasPriceApi:
      "https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice",
    token: "MATIC",
    // gasPriceApi: "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
    // token: "ETH",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
