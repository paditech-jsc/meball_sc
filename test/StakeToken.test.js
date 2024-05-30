const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");

describe("NFT stake", async () => {
    let owner;
    let addr1;
    let addr2;
    let tokenStakeContract;
    let rewardToken;
    let season;
    before(async () => {
        [owner, addr1, addr2] = await ethers.getSigners();
        rewardToken = await (await ethers.getContractFactory("Meball")).deploy();

        const tokenStakeFactory = await ethers.getContractFactory("TokenStake");
        tokenStakeContract = await upgrades.deployProxy(tokenStakeFactory, [rewardToken.address, rewardToken.address], { kind: "uups" })

        season = 1;
    });

    describe("Stake NFT", () => {

        it("Fail if you are not enough token to stake", async () => {
            await expect(tokenStakeContract.connect(addr1).stake(0, season)).to.revertedWith("InsufficientBalance");
            await expect(tokenStakeContract.connect(addr1).stake(1000, season)).to.revertedWith("InsufficientBalance");
        });

        it("Stake token successfully", async () => {
            rewardToken.connect(addr1).mint(1000)
            await rewardToken.connect(addr1).approve(tokenStakeContract.address, 500);
            await tokenStakeContract.connect(addr1).stake(500, season);
            const stakeInfo = await tokenStakeContract.stakeInfos(addr1.address, 1);
            expect(stakeInfo.amount).to.equal(500);

            //stake more
            await rewardToken.connect(addr1).approve(tokenStakeContract.address, 500);
            await tokenStakeContract.connect(addr1).stake(500, season);
            const stakeMoreInfo = await tokenStakeContract.stakeInfos(addr1.address, 1);
            expect(stakeMoreInfo.amount).to.equal(1000);
        })

    });

    describe("Rewards", function () {
        beforeEach(async function () {
            await rewardToken.connect(addr1).mint(ethers.utils.parseEther("100"))
            await rewardToken.connect(addr1).approve(tokenStakeContract.address, ethers.utils.parseEther("100"));
            await tokenStakeContract.connect(addr1).stake(ethers.utils.parseEther("100"), 1);
        });

        it("Should allow the owner to create rewards", async function () {
            await tokenStakeContract.createReward([addr1.address], [10], 1);

            const rewardAmount = await tokenStakeContract.rewardAmounts(addr1.address, 1);
            expect(rewardAmount.toString()).to.equal(ethers.utils.parseEther("10"));
        });

        it("Should allow users to claim rewards", async function () {
            await tokenStakeContract.createReward([addr1.address], [10], 1);
            const balanceBefore = await rewardToken.balanceOf(addr1.address);
            console.log(balanceBefore.toString())
            await tokenStakeContract.connect(addr1).claim(1);
            const balanceAfter = await rewardToken.balanceOf(addr1.address);
            console.log(balanceAfter.toString())
            expect(balanceAfter.sub(balanceBefore)).to.equal(ethers.utils.parseEther("10"));
        });

        it("Should revert if there is nothing to claim", async function () {
            await expect(tokenStakeContract.connect(addr1).claim(1)).to.be.revertedWith("NothingToClaim");
        });
    });
    // describe("create reward", () => {
    //     it("Set the reward successfully", async () => {

    //         tx = await administrator
    //             .connect(owner)
    //             .submitTransaction(
    //                 nftStakeContract.address,
    //                 0,
    //                 nftStakeContract.interface.encodeFunctionData("createReward", [
    //                     [addr1.address, addr2.address], [50000, 50000], 100000, 1
    //                 ])
    //             );
    //         await tx.wait(0);

    //         tx = await administrator.connect(addr1).confirmTransaction(0);
    //         await tx.wait(0);

    //         tx = await administrator.connect(owner).confirmTransaction(0);
    //         await tx.wait(0);

    //         tx = await administrator.connect(owner).executeTransaction(0);
    //         await tx.wait(0);
    //     })

    // })

    // describe("claim", () => {
    //     before(async () => {
    //         rewardToken.connect(owner).transfer(nftStakeContract.address, ethers.utils.parseEther("100000"))
    //     })
    //     it(" unstake nft and claim token successfully", async () => {
    //         await nftStakeContract.connect(addr1).claim([0, 1], 1);
    //         expect(await nftContract.ownerOf(0)).to.equal(addr1.address)
    //         expect(await nftContract.ownerOf(1)).to.equal(addr1.address)

    //         // //other address claim success
    //         // await nftStakeContract.connect(addr2).claim([0, 1], 1);
    //         // expect(await nftContract.ownerOf(0)).to.equal(addr1.address)
    //         // expect(await nftContract.ownerOf(1)).to.equal(addr1.address)
    //     })
    // })
});
