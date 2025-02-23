const hre = require("hardhat");

async function main() {
    const SimpleStorage = await hre.ethers.getContractFactory("NatureCoin");
    const simpleStorage = await SimpleStorage.deploy();

    await simpleStorage.waitForDeployment();
    console.log(`NatureCoin deployed to: ${simpleStorage.target}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
