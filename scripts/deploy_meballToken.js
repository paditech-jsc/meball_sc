const hre = require("hardhat");

async function main() {

    const meballFactory = await hre.ethers.getContractFactory("Meball");
    const meballContract = await meballFactory.deploy("Meball", "MEBALL", ethers.utils.parseEther("100000000000000"), "0x13308228263d57fCc507cd0CD76ED441b784b852");

    console.log("meball", meballContract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });