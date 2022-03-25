import { expect } from "chai";
import { ethers } from "hardhat";

describe("Taxes", function () {
  let contract;
  let deployedContract;

  beforeEach(async function () {
    contract = await ethers.getContractFactory("SERC20Mock");
    deployedContract = await contract.deploy();
    await deployedContract.deployed();
  });

  it("Should display the correct total buy tax", async () => {
    const buyTax = await deployedContract.sercBuyTotalTax();

    expect(buyTax.toNumber()).to.be.equal(10);
  });

  it("Should display the correct total sell tax", async () => {
    const sellTax = await deployedContract.sercSellTotalTax();

    expect(sellTax.toNumber()).to.be.equal(10);
  });

  it("Should revert when set above threshold", async () => {
    await expect(deployedContract.setBuyTax(30, 30)).to.be.revertedWith(
      "SERC20: Round trip tax rate can not be set higher than 20%"
    );
  });

  it("Should confirm when set below threshold", async () => {
    await expect(deployedContract.setBuyTax(5, 1)).to.not.be.revertedWith(
      "SERC20: Round trip tax rate can not be set higher than 20%"
    );

    const taxes = await deployedContract.sercBuyTax();

    expect(taxes[0].toNumber()).to.be.equal(5);
    expect(taxes[1].toNumber()).to.be.equal(1);
  });

  it("Should confirm when set below threshold then fail when are set above threshold", async () => {
    let taxes;

    await expect(deployedContract.setBuyTax(5, 1)).to.not.be.revertedWith(
      "SERC20: Round trip tax rate can not be set higher than 20%"
    );

    taxes = await deployedContract.sercBuyTax();

    expect(taxes[0].toNumber()).to.be.equal(5);
    expect(taxes[1].toNumber()).to.be.equal(1);

    await expect(deployedContract.setBuyTax(30, 30)).to.be.revertedWith(
      "SERC20: Round trip tax rate can not be set higher than 20%"
    );

    taxes = await deployedContract.sercBuyTax();

    expect(taxes[0].toNumber()).to.be.equal(5);
    expect(taxes[1].toNumber()).to.be.equal(1);
  });
});
