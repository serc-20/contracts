import { expect } from "chai";
import { ethers } from "hardhat";

describe("Max Wallet", function () {
  let contract;
  let deployedContract;

  beforeEach(async function () {
    contract = await ethers.getContractFactory("SERC20Mock");
    deployedContract = await contract.deploy();
    await deployedContract.deployed();
  });

  it("Should confirm when raising the default max wallet", async () => {
    await expect(
      deployedContract.sercSetMaxWallet("30000000000000000000000000")
    ).to.not.be.reverted;

    const maxWallet = await deployedContract.sercMaxWallet();

    expect(maxWallet).to.be.equal(
      ethers.BigNumber.from("30000000000000000000000000")
    );
  });

  it("Should revert when lowering the max wallet", async () => {
    await expect(
      deployedContract.sercSetMaxWallet("30000000000000000000000000")
    ).to.not.be.reverted;

    const maxWallet = await deployedContract.sercMaxWallet();

    expect(maxWallet).to.be.equal(
      ethers.BigNumber.from("30000000000000000000000000")
    );

    await expect(
      deployedContract.sercSetMaxWallet("20000000000000000000000000")
    ).to.be.revertedWith("SERC20: Can not lower the max wallet amount");
  });

  it("Should revert when the new value is lower than the current max tx", async () => {
    await expect(
      deployedContract.sercSetMaxWallet("30000000000000000000000000")
    ).to.not.be.reverted;
    await expect(deployedContract.sercSetMaxTx("25000000000000000000000000")).to
      .not.be.reverted;

    await expect(
      deployedContract.sercSetMaxWallet("25000000000000000000000000")
    ).to.be.reverted;
  });
});
