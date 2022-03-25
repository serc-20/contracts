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

  console.log("checking max with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const traderFactory = await ethers.getContractFactory("SERC20");

  const contract = traderFactory.attach(
    "0x02f576FdBBDED58c150e01C073899A90a069d9C9"
  );

  const maxTx = await contract.maxTx();
  const maxWallet = await contract.maxWallet();

  console.log(`Max Tx: ${maxTx.toString()}`);
  console.log(`Max Wallet: ${maxWallet.toString()}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => (process.exitCode = 0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
