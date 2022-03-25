import { expect } from "chai";
import { ethers } from "hardhat";

describe("Max Tx", function () {
  let contract;
  let deployedContract;

  beforeEach(async function () {
    contract = await ethers.getContractFactory("SERC20Mock");
    deployedContract = await contract.deploy();
    await deployedContract.deployed();
  });

  it("Should confirm when raising the default max tx", async () => {
    await expect(deployedContract.sercSetMaxTx("20000000000000000000000000")).to
      .not.be.reverted;

    const maxTx = await deployedContract.sercMaxTx();

    expect(maxTx).to.be.equal(
      ethers.BigNumber.from("20000000000000000000000000")
    );
  });

  it("Should revert when lowering the max tx", async () => {
    await expect(deployedContract.sercSetMaxTx("20000000000000000000000000")).to
      .not.be.reverted;

    const maxTx = await deployedContract.sercMaxTx();

    expect(maxTx).to.be.equal(
      ethers.BigNumber.from("20000000000000000000000000")
    );

    await expect(
      deployedContract.sercSetMaxTx("10000000000000000000000000")
    ).to.be.revertedWith("SERC20: Can not lower the max tx amount");
  });

  it("Should revert when the new value is higher than the current max wallet", async () => {
    await expect(
      deployedContract.sercSetMaxTx("50000000000000000000000000")
    ).to.be.revertedWith(
      "SERC20: Can not set max tx higher than the max wallet"
    );
  });
});
