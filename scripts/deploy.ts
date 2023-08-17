import { ethers } from "hardhat";

async function main() {
  const HackBank = await ethers.getContractFactory("HackBank");
  const hackbank = await HackBank.deploy();

  await hackbank.deployed();

  console.log("deployed to:", hackbank.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat verify --network optimisticEthereum 0xC519bAb3dA740d92e40c3e34226d34eb0b512b78
