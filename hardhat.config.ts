import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const DEFAULT_PRIVATE_KEY =
  "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

const { PRIVATE_KEY, ETHERSCAN_API_KEY, OPTIMISIMSCAN_API_KEY } = process.env;

const optimismGoerliPrivateKey = PRIVATE_KEY || DEFAULT_PRIVATE_KEY;
const optimismPrivatekey = PRIVATE_KEY || DEFAULT_PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    goerliOptimism: {
      accounts: [optimismGoerliPrivateKey],
      chainId: 420,
      url: `https://opt-goerli.g.alchemy.com/v2/f1wk-yxNGVNT9KKGl5AGhv80EAWXkIOm`,
      gasPrice: 35000000000,
    },
    optimisticEthereum: {
      accounts: [optimismPrivatekey],
      chainId: 10,
      url: "https://optimism-mainnet.infura.io/v3/ffc8282114664deeaec282fbe7a5dfaa",
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      goerli: `${ETHERSCAN_API_KEY}`,
      goerliOptimism: "ZSXIQDG42RN9364Y1B421JN8V9FJWWTSNB",
      optimisticEthereum: `${OPTIMISIMSCAN_API_KEY}`,
    },
    customChains: [
      {
        network: "goerliOptimism",
        chainId: 420,
        urls: {
          apiURL: "https://api-goerli-optimism.etherscan.io/api",
          browserURL: "https://goerli-optimism.etherscan.io",
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};

export default config;
