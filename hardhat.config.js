require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

const { PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.24",
  networks: {
    arbitrum: {
      url: "https://arbitrum.llamarpc.com",
      accounts: [PRIVATE_KEY].filter(Boolean)
    }
  }
};
