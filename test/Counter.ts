import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("Counter", function () {
  it("Should emit the Increment event when calling the inc() function", async function () {
    const counter = await ethers.deployContract("Counter");

    await expect(counter.inc()).to.emit(counter, "Increment").withArgs(1n);
  });

  it("The sum of the Increment events should match the current value", async function () {
    const counter = await ethers.deployContract("Counter");
    const deploymentBlockNumber = await ethers.provider.getBlockNumber();

    // run a series of increments
    for (let i = 1; i <= 10; i++) {
      await counter.incBy(i);
    }

    const events = await counter.queryFilter(
      counter.filters.Increment(),
      deploymentBlockNumber,
      "latest",
    );

    // check that the aggregated events match the current value
    let total = 0n;
    for (const event of events) {
      total += event.args.by;
    }

    expect(await counter.x()).to.equal(total);
  });

  it("Should decrease the counter by one when calling dec()", async function () {
    const counter = await ethers.deployContract("Counter");
    await counter.incBy(2n);

    await expect(counter.dec()).to.emit(counter, "Decrement").withArgs(1n);
    expect(await counter.x()).to.equal(1n);
  });

  it("Should revert when calling dec() at zero", async function () {
    const counter = await ethers.deployContract("Counter");

    await expect(counter.dec()).to.be.revertedWith("dec: counter is already zero");
    expect(await counter.x()).to.equal(0n);
  });
});
