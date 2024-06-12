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
        bscTestnet: {
            url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
            chainId: 97,
            accounts: [Secrets.privateKey]
        },
        chiliz_spicy: {
            url: "https://spicy-rpc.chiliz.com",
            chainId: 88882,
            accounts: [Secrets.privateKey]
        },
        chiliz: {
            url: "https://rpc.ankr.com/chiliz",
            chainId: 88888,
            accounts: [Secrets.privateKey]
        }
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS !== undefined,
        currency: "USD",
    },
    etherscan: {
        apiKey: {
            chiliz_spicy: "chiliz_spicy",  // apiKey is not required, just set a placeholder
            chiliz: "chiliz",
        },
        customChains: [
            {
                network: "chiliz_spicy",
                chainId: 88882,
                urls: {
                    apiURL: "https://api.routescan.io/v2/network/testnet/evm/88882/etherscan",
                    browserURL: "https://testnet.chiliscan.com"
                }
            },
            {
                network: "chiliz",
                chainId: 88888,
                urls: {
                    apiURL: "https://api.routescan.io/v2/network/mainnet/evm/88888/etherscan",
                    browserURL: "https://chiliscan.com"
                }
            }
        ]
    },
};

