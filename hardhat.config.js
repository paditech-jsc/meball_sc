require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("ethereum-waffle");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("@nomiclabs/hardhat-ethers");
require("hardhat-deploy-ethers");
require("@nomiclabs/hardhat-solhint");
require("@nomiclabs/hardhat-web3");
require("dotenv/config");
require("hardhat-deploy");
require("hardhat-preprocessor");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-gas-reporter");

const Secrets = require("./secrets");

module.exports = {
    solidity: {
        version: "0.8.17",
        settings: {
            viaIR: false,
            optimizer: {
                enabled: true,
                runs: 200,
            },
            metadata: {
                bytecodeHash: "none",
            },
        },
    },
    networks: {
        localhost: {
            url: "http://127.0.0.1:8545",
        },
        hardhat: {
            chainId: 1337,
            mining: {
                auto: true,
                interval: 5000,
            },
            allowUnlimitedContractSize: true,
        },
        baseSepolia: {
            url: "https://base-sepolia.blockpi.network/v1/rpc/public",
            chainId: 84532,
            accounts: [Secrets.privateKey]
        },
        base: {
            url: "https://base.publicnode.com",
            chainId: 8453,
            accounts: [Secrets.privateKey]
        }
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS !== undefined,
        currency: "USD",
    },
    etherscan: {
        apiKey: Secrets.explorer_key.BASE,
    }
};

