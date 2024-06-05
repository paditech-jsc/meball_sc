const hre = require("hardhat");

async function main() {
    const meballNFTFactory = await hre.ethers.getContractFactory("MeballNFT");
    const probabilities = ["1", "8", "3", "3", "1", "3", "1", "3", "8", "2", "3", "8", "3", "2", "8", "1", "3", "8", "8", "8", "3", "3", "1", "8"];
    const ipfsLinks = [
        "https://ipfs.filebase.io/ipfs/Qmcjbi1aYdjcKPC72MnZSB3JDbvo8EVh3uxFt84Hrzfp61",
        "https://ipfs.filebase.io/ipfs/QmSrohLgwdgWq1o4tCpKEpSZob2C5Z3XSogN6nBdvo9Atb",
        "https://ipfs.filebase.io/ipfs/QmYqasNhV1mAqhKUC8gYrCwHLBXxgcYmvsqvCAZpvozFob",
        "https://ipfs.filebase.io/ipfs/QmR5HEJN3VByQJL7pyimAehN4didVhHHD32WAE64MJh5w2",
        "https://ipfs.filebase.io/ipfs/QmUqXjNKkdEZYKc5ps741jm1Y9Rh8cutqj8LNAGtDeGuGt",
        "https://ipfs.filebase.io/ipfs/QmdR65D8oXHnYPQAjTQmQq7TgybX7pTTGaSs9VkXPBfpzn",
        "https://ipfs.filebase.io/ipfs/QmZX4Y1HmEfP9yR3319eGSxkYN5cZBnJ716i7yUcFLpkLX",
        "https://ipfs.filebase.io/ipfs/Qmf5QaEZh9UfgZ3GvQRnYg6Droq68sUXmRrzcVP68sGAJq",
        "https://ipfs.filebase.io/ipfs/Qmeixec47z6t2uR3xxrNpiC9S3uuJNwksfgvkFDkPtcTJ6",
        "https://ipfs.filebase.io/ipfs/QmSQUbk14m8E55dqz1gwogtZPJa813FctfKEdVdLWyNrHM",
        "https://ipfs.filebase.io/ipfs/QmNwzfV8y5SXNv4PciwTbUEdVpUCguhThR1J3mhPZGZB9S",
        "https://ipfs.filebase.io/ipfs/QmcvnshLf7beHB1YyKozRvNSa2QqMecE5tXzoBu8rduZ3f",
        "https://ipfs.filebase.io/ipfs/QmPPgoFPEJbno2Z4azCPDjtdRUAtyesfpAW53VGRHZbFpX",
        "https://ipfs.filebase.io/ipfs/QmSdjSyd3U2ayJY9HjsYDJaugpWbqsLVp5efWPnjNkq5aW",
        "https://ipfs.filebase.io/ipfs/QmVvuCyeY8YHkZRGVxH8ZizvKwhzG1Z4Uex1DggSLxDexC",
        "https://ipfs.filebase.io/ipfs/QmP5sm22sNG6a9KSBnna7pU6jPSAfb6Ud6z4u5cVFKSpeU",
        "https://ipfs.filebase.io/ipfs/QmTkiaFDEWK5YWjvXpMbuoi2NHjPTWbVJ6x6ryifqJxbdX",
        "https://ipfs.filebase.io/ipfs/QmYbMu9ftCq35Nys5fJy7dFyqXmHiaJanGdb5EVvcKXg9F",
        "https://ipfs.filebase.io/ipfs/QmTMFpcLtH4NDkgXSRBKgugSbKhmujcimUcC8FcPnd8u5J",
        "https://ipfs.filebase.io/ipfs/QmdPcqRCzoHc2foTjGUcFV698ubS1U1x7LQmzFy3vnFK97",
        "https://ipfs.filebase.io/ipfs/QmPq3eDbWSgK1ghYuBajJew2X7bP9LvRRmwzP27ho6qaga",
        "https://ipfs.filebase.io/ipfs/QmPCHmhsXi7NfLeTjzUZVBasybNd8uMUCQDxWejtNXKrzX",
        "https://ipfs.filebase.io/ipfs/QmUAysuc9Ckr8ydRCqNjrrNPpXYa34V3VnXbYTmC7SzSZx",
        "https://ipfs.filebase.io/ipfs/QmZGKtyMpPmx1ESBczo6gBM1dFnNVsRmnN4pbX7eNP1RiZ"
    ];
    const meballNFTContract = await meballNFTFactory.deploy(probabilities, ipfsLinks, hre.ethers.utils.parseEther("0.00001"));

    console.log("meball NFT", meballNFTContract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });