import { expect } from "chai";
import { ethers } from "hardhat";

describe("Trading", function () {
  let contract;
  let deployedContract;

  beforeEach(async function () {
    contract = await ethers.getContractFactory("SERC20Mock");
    deployedContract = await contract.deploy();
    await deployedContract.deployed();
  });

  it("Should confirm when setting enabled for the first time", async () => {
    let enabled;

    enabled = await deployedContract.sercTradingEnabled();

    expect(enabled).to.be.equal(false);

    await expect(
      deployedContract.sercSetTradingEnabled()
    ).to.not.be.revertedWith("sERC20: Trading is already enabled");

    enabled = await deployedContract.sercTradingEnabled();

    expect(enabled).to.be.equal(true);
  });

  it("Should revert when setting is already enabled", async () => {
    let enabled;

    enabled = await deployedContract.sercTradingEnabled();

    expect(enabled).to.be.equal(false);

    await expect(
      deployedContract.sercSetTradingEnabled()
    ).to.not.be.revertedWith("sERC20: Trading is already enabled");

    enabled = await deployedContract.sercTradingEnabled();

    expect(enabled).to.be.equal(true);

    await expect(deployedContract.sercSetTradingEnabled()).to.be.revertedWith(
      "sERC20: Trading is already enabled"
    );

    enabled = await deployedContract.sercTradingEnabled();

    expect(enabled).to.be.equal(true);
  });
});
