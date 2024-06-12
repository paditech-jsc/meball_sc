const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");

describe("Meball NFT", async () => {
    let owner;
    let addr1;
    let addr2;
    let meballNFTContract;
    let signature;
    let mintFee;

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
        const probabilities = ["1", "8", "3", "3", "1", "3", "1", "3", "8", "2", "3", "8", "3", "2", "8", "1", "3", "8", "8", "8", "3", "3", "1", "8"];
        const ipfsLinks = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
        mintFee = ethers.utils.parseEther("0.01");
        meballNFTContract = await (await ethers.getContractFactory("MeballNFT")).deploy(probabilities, ipfsLinks, mintFee)

    });

    describe("Deploy correctly", () => {
        it("Should deploy with correct initial values", async function () {
            expect(await meballNFTContract.mintFee()).to.equal(mintFee);
            expect(await meballNFTContract.nextTokenId()).to.equal(0);
        });
    })

    describe("Mint token", () => {
        it("Should mint NFTs correctly", async () => {
            const randomValues = ["randomValue1", "randomValue2"];
            const hashRandomValues = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(randomValues.join('')));
            signature = createSignature(meballNFTContract.address, owner, addr1.address, hashRandomValues, 14)
            const tx = await meballNFTContract.connect(addr1).mintNFTs({
                requester: addr1.address,
                randomValues: randomValues,
                hashRandomValues: hashRandomValues,
                nonce: 14
            }, signature, {
                value: mintFee.mul(randomValues.length)
            });

            expect(await meballNFTContract.nextTokenId()).to.equal(randomValues.length);
            expect(await meballNFTContract.tokenIdToTeam(0)).to.be.within(0, 23);
        });

        it("Should reject minting with insufficient fee", async function () {
            const randomValues = ["randomValue1", "randomValue2"];
            const hashRandomValues = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(randomValues.join('')));
            signature = createSignature(meballNFTContract.address, owner, addr1.address, hashRandomValues, 14)
            await expect(
                meballNFTContract.connect(addr1).mintNFTs({
                    requester: addr1.address,
                    randomValues: randomValues,
                    hashRandomValues: hashRandomValues,
                    nonce: 14
                }, signature, {
                    value: mintFee
                })
            ).to.be.revertedWith("Mint Fee not enough");
        });

        it("Should not allow duplicate signatures", async function () {
            const randomValues = ["test_value_168"];
            const hashRandomValues = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(randomValues.join('')));
            signature = createSignature(meballNFTContract.address, owner, addr1.address, hashRandomValues, 14)

            await meballNFTContract.connect(addr1).mintNFTs({
                requester: addr1.address,
                randomValues: randomValues,
                hashRandomValues: hashRandomValues,
                nonce: 14
            }, signature, {
                value: mintFee
            })

            await expect(
                meballNFTContract.connect(addr1).mintNFTs({
                    requester: addr1.address,
                    randomValues: randomValues,
                    hashRandomValues: hashRandomValues,
                    nonce: 14
                }, signature, {
                    value: mintFee
                })
            ).to.be.revertedWith("Signature already used");

        });


    });

    describe("setMintFee", function () {
        it("Should set the mint fee correctly", async function () {
            const newMintFee = ethers.utils.parseEther("0.2");
            await meballNFTContract.setMintFee(newMintFee);
            expect(await meballNFTContract.mintFee()).to.equal(newMintFee);
        });

        it("Should revert if non-owner tries to set the mint fee", async function () {
            const newMintFee = ethers.utils.parseEther("0.2");
            await expect(
                meballNFTContract.connect(addr1).setMintFee(newMintFee)
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });

    describe("withdraw", function () {

        it("Should withdraw ETH correctly", async function () {
            const initialOwnerBalance = await owner.getBalance();
            await meballNFTContract.withdraw();
            const finalOwnerBalance = await owner.getBalance();

            expect(finalOwnerBalance).to.be.above(initialOwnerBalance);
        });

        it("Should revert if non-owner tries to withdraw", async function () {
            await expect(
                meballNFTContract.connect(addr1).withdraw()
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should revert if there is no balance to withdraw", async function () {
            await expect(meballNFTContract.withdraw()).to.be.revertedWith("No balance to withdraw");
        });
    });

});
