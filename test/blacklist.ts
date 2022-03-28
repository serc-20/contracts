import { expect } from "chai";
import { ethers } from "hardhat";

describe("Blacklist", function () {
  let contract;
  let deployedContract;

  beforeEach(async function () {
    contract = await ethers.getContractFactory("SERC20Mock");
    deployedContract = await contract.deploy();
    await deployedContract.deployed();
  });

  it("Should confirm when setting a valid address", async () => {
    await expect(
      deployedContract.sercSetBlacklisted(
        ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"],
        true
      )
    ).to.not.be.reverted;

    const blacklisted = await deployedContract.sercIsBlacklisted(
      "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
    );

    expect(blacklisted).to.be.equal(true);
  });

  it("Should confirm when removing a valid address", async () => {
    await expect(
      deployedContract.sercSetBlacklisted(
        ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"],
        true
      )
    ).to.not.be.reverted;

    const blacklisted = await deployedContract.sercIsBlacklisted(
      "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
    );

    expect(blacklisted).to.be.equal(true);

    await expect(
      deployedContract.sercSetBlacklisted(
        ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"],
        false
      )
    ).to.not.be.reverted;

    const blacklistedStill = await deployedContract.sercIsBlacklisted(
      "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
    );

    expect(blacklistedStill).to.be.equal(false);
  });

  it("Should revert when more than 10 minutes have passed since trading was enabled", async () => {
    await deployedContract.sercSetTradingEnabled();

    const enabled = await deployedContract.sercTradingEnabled();

    expect(enabled).to.be.equal(true);

    const skipDuration = 1000 * 60 * 11; // 11 minutes

    const blockNumBefore = await ethers.provider.getBlockNumber();
    const blockBefore = await ethers.provider.getBlock(blockNumBefore);
    const timestampBefore = blockBefore.timestamp;

    await ethers.provider.send("evm_mine", [
      ethers.utils.hexlify(timestampBefore + skipDuration),
    ]);

    await expect(
      deployedContract.sercSetBlacklisted(
        ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8"],
        true
      )
    ).to.be.revertedWith(
      "sERC20: Can not blacklist more than 10 minutes after trading has been enabled"
    );
  });

  it("Should revert when setting the pair address", async () => {
    await expect(
      deployedContract.sercSetBlacklisted(
        ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"],
        true
      )
    ).to.be.revertedWith("sERC20: Can not blacklist the pair address");
  });

  it("Should revert when setting the router address", async () => {
    await expect(
      deployedContract.sercSetBlacklisted(
        ["0xFABB0ac9d68B0B445fB7357272Ff202C5651694a"],
        true
      )
    ).to.be.revertedWith("sERC20: Can not blacklist the router address");
  });

  it("Should revert when setting the contract address", async () => {
    await expect(
      deployedContract.sercSetBlacklisted([deployedContract.address], true)
    ).to.be.revertedWith("sERC20: Can not blacklist the contract address");
  });
});
