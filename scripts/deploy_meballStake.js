const hre = require("hardhat");

async function main() {
    const MeballStake = await hre.ethers.getContractFactory("MeballStake");
    const MeballStakeProxy = await upgrades.deployProxy(MeballStake, ["0x27ACcfb57c6EE88667929B2e26951CFe7BdC3C41", "0x27ACcfb57c6EE88667929B2e26951CFe7BdC3C41"], {
        kind: "uups",
    });

    console.log(MeballStakeProxy.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });