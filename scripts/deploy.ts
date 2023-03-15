const hre = require("hardhat");

const main = async () => {
  const GrimoireContractFactory = await hre.ethers.getContractFactory("Grimoire");
  const GrimoireContract = await GrimoireContractFactory.deploy();
  await GrimoireContract.deployed();
  console.log("Contract deployed to:", GrimoireContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();