const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NatureCoin", function () {
    let NatureCoin, natureCoin, owner, addr1, addr2;
    const initialPrice = 1e15
    const finalPrice = 2e15
    this.beforeAll(async function () {
        NatureCoin = await ethers.getContractFactory("NatureCoin");
        [owner, addr1, addr2] = await ethers.getSigners();
        natureCoin = await NatureCoin.deploy(
            owner.address, // initialOwner
            1000000,       // totalSupply
            initialPrice, // initialPrice
            finalPrice, // regularSalePrice
            5,             // stakingRewardRate
            60 * 60 * 24 * 30, // minUnstakingPeriod
            60 * 60 * 24 * 1,  // stakingRewardFrequency
            1000,          // whiteListCapacity
            5,             // whiteListDiscount
            500,           // minTokensToBuy
            10000          // minStakingAmount
        );
        await natureCoin.waitForDeployment();
    });

    it("Presale should be closed", async function () {
        var preSaleActive = await natureCoin.presaleIsActive();
        expect(preSaleActive).to.equal(false);
    });

    it("Initial address balance should be 0", async function () {
        const balanceBefore = await natureCoin.balanceOf(addr1.address);
        expect(balanceBefore).to.equals(0);
    });

    it("It should revert", async function () {
        let reverted = natureCoin.revertTransaction();
        await expect(natureCoin.revertTransaction()).to.be.revertedWith("Testing comment")
    });
    it("Should fail to buy tokens before presale starts", async function () {
        const buyAmount = ethers.parseEther("1");
        await expect(natureCoin.connect(addr1).buyTokens({value:buyAmount})).to.be.revertedWith("Sale not active")
    });

    it("Should start presale correctly", async function () {
        const currentTimestamp = Math.floor(Date.now() / 1000);
        const startTime = currentTimestamp + 60 * 60 * 24;
        const endTime = startTime + 4 * 60 * 60 * 24;
        const steps = 4;
        await natureCoin.startPreSale(startTime, endTime, steps);
        const presaleStarted = await natureCoin.presaleIsActive();
        expect(presaleStarted).to.equal(true);
    });

    it("Should correctly calculate the current step during presale", async function () {
        const currentTimestamp = Math.floor(Date.now() / 1000); // Get current time in seconds
        const startTime = currentTimestamp; 
        const endTime = startTime + 60 * 60; // Presale ends in 1 hour
        const steps = 4;  // Presale duration of 4 steps

        // Start the presale with initial time parameters
        await natureCoin.startPreSale(startTime, endTime, steps);

        // Step 0 - Right after start
        let calcStep = await natureCoin.getCurrentStep();
        expect(calcStep).to.equal(0, "Step should be 0 after 0 minutes");

        // Start presale with 15 minutes before start time
        await natureCoin.startPreSale(startTime - 15 * 60, endTime - 15 * 60, steps);
        calcStep = await natureCoin.getCurrentStep();
        expect(calcStep).to.equal(1, "Step should be 1 after 15 minutes");

        // Start presale with 30 minutes before start time
        await natureCoin.startPreSale(startTime - 30 * 60, endTime - 30 * 60, steps);
        calcStep = await natureCoin.getCurrentStep();
        expect(calcStep).to.equal(2, "Step should be 2 after 30 minutes");

        // Start presale with 45 minutes before start time
        await natureCoin.startPreSale(startTime - 45 * 60, endTime - 45 * 60, steps);
        calcStep = await natureCoin.getCurrentStep();
        expect(calcStep).to.equal(3, "Step should be 3 after 45 minutes");

        // Start presale with 60 minutes before start time
        await natureCoin.startPreSale(startTime - 60 * 60, endTime - 60 * 60, steps);
        calcStep = await natureCoin.getCurrentStep();
        expect(calcStep).to.equal(4, "Step should be 4 after 60 minutes");
    });


    it("Should calculate correct price at each presale step", async function () {
        const currentTimestamp = Math.floor(Date.now() / 1000); // Get current time in seconds
        const startTime = currentTimestamp; //
        const steps = 4;
        const endTime = startTime + 60 * 60; // Presale ends in 1 hour
        let priceIncrease = (finalPrice-initialPrice)/4
        // Start the presale
        await natureCoin.startPreSale(startTime, endTime, steps);

        // Step 0: Price should be equal to initial price
        let calcPrice = await natureCoin.calculatePrice();
        let expectedPrice = initialPrice;
        expect(calcPrice).to.equal(expectedPrice, "At step 0 price should be equal to initial price");

        // Step 1: 16 minutes before start time
        await natureCoin.startPreSale(startTime - 16 * 60, endTime - 16 * 60, steps);
        calcPrice = await natureCoin.calculatePrice();
        expectedPrice = initialPrice + priceIncrease;
        expect(calcPrice).to.equal(expectedPrice, "At step 1 price should be equal to initial price + 1/4");

        // Step 2: 30 minutes before start time
        await natureCoin.startPreSale(startTime - 30 * 60, endTime - 30 * 60, steps);
        calcPrice = await natureCoin.calculatePrice();
        expectedPrice = initialPrice + (priceIncrease*2);
        expect(calcPrice).to.equal(expectedPrice, "At step 2 price should be equal to initial price + 1/2");

        // Step 3: 45 minutes before start time
        await natureCoin.startPreSale(startTime - 45 * 60, endTime - 45 * 60, steps);
        calcPrice = await natureCoin.calculatePrice();
        expectedPrice = initialPrice + (priceIncrease*3);
        expect(calcPrice).to.equal(expectedPrice, "At step 3 price should be equal to initial price + 3/4");

        // Step 4: 60 minutes before start time
        await natureCoin.startPreSale(startTime - 60 * 60, endTime - 60 * 60, steps);
        calcPrice = await natureCoin.calculatePrice();
        expectedPrice = initialPrice + (priceIncrease*4);
        expect(calcPrice).to.equal(expectedPrice, "At step 4 price should be equal to initial price + 1");

        // After presale: Price should be the final price
        await natureCoin.startPreSale(startTime - 80 * 60, endTime - 80 * 60, steps);
        calcPrice = await natureCoin.calculatePrice();
        expectedPrice = finalPrice;
        expect(calcPrice).to.equal(expectedPrice, "After presale price should be final price.");
    });
});
