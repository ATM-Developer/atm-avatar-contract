
require("@nomicfoundation/hardhat-toolbox");
//require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.1",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  },
  defaultNetwork: "bsc_test",
  networks: {
    bsc_test: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      accounts: [""]
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: []
    }
  },

  etherscan: {
    apiKey: "S6T8NYNYVJ33TBCCTW1Q55B7ZMTPQAI712" //bscscan apiKey
  }

}