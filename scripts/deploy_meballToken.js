const hre = require("hardhat");

async function main() {

    const meballFactory = await hre.ethers.getContractFactory("Meball");
    const meballContract = await meballFactory.deploy();

    // console.log("cp address", cpContract.address);
    console.log("meball", meballContract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });