const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");


describe("CP Token", async () => {
    let owner;
    let addr1;
    let addr2;
    let meballNFTContract;
    let signature;

    const createSignature = async (
        meballNFTContractAddress,
        signer,
        _requester,
        _hashRandomValues,
        _nonce
    ) => {
        let domain = {
            name: "MeballNFT",
            version: "1",
            chainId: 1337,
            verifyingContract: meballNFTContractAddress,
        };

        let types = {
            params: [
                { name: "_requester", type: "address" },
                { name: "_hashRandomValues", type: "bytes32" },
                { name: "_nonce", type: "uint256" },
            ],
        };

        let value = {
            _requester,
            _hashRandomValues,
            _nonce
        };

        return signer._signTypedData(domain, types, value);
    };

    before(async () => {
        [owner, addr1, addr2] = await ethers.getSigners();
        deadline = Math.floor(Date.now() / 1000 + 5 * 60);
        const probabilities = ["1", "8", "3", "3", "1", "3", "1", "3", "8", "2", "3", "8", "3", "2", "8", "1", "3", "8", "8", "8", "3", "3", "1", "8"];
        const ipfsLinks = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
        meballNFTContract = await (await ethers.getContractFactory("MeballNFT")).deploy(probabilities, ipfsLinks)

    });

    describe("Mint token", () => {
        before(async () => {
            const randomValues = ["abc", "xyz"];
            const hashRandomValues = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(randomValues.join('')));
            console.log(hashRandomValues)
            signature = await createSignature(
                meballNFTContract.address,
                owner,
                owner.address,
                hashRandomValues,
                14
            );

            const tx = await meballNFTContract.mintNFTs({
                requester: owner.address,
                hashRandomValues,
                nonce: 14,
            }, signature, randomValues)
            await tx.wait();

        });

        it("Balance of requester is greater than zero", async () => {

        });


    });

});
