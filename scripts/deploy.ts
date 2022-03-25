// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const traderFactory = await ethers.getContractFactory("TEST");
  const traderContract = await traderFactory.deploy({
    // gasLimit: ethers.utils.hexlify(ethers.BigNumber.from("8000000")),
    // maxFeePerGas: ethers.utils.parseUnits("30", "gwei"),
    // maxPriorityFeePerGas: ethers.utils.parseUnits("30", "gwei"),
  });

  await traderContract.deployed();

  console.log("SERC20 deployed to:", traderContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => (process.exitCode = 0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
