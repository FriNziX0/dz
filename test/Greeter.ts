import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("Greeter", function () {
  const initialSupply = 1_000n;
  const unit = 10n ** 18n;

  async function deployGreeter() {
    return ethers.deployContract("Greeter", ["Hello", "Greeter Token", "GRT", initialSupply]);
  }

  it("assigns the deployer as owner, sets metadata, and mints the initial supply", async function () {
    const [owner] = await ethers.getSigners();
    const greeter = await deployGreeter();

    expect(await greeter.owner()).to.equal(owner.address);
    expect(await greeter.greeting()).to.equal("Hello");
    expect(await greeter.name()).to.equal("Greeter Token");
    expect(await greeter.symbol()).to.equal("GRT");
    expect(await greeter.decimals()).to.equal(18n);
    expect(await greeter.totalSupply()).to.equal(initialSupply * unit);
    expect(await greeter.balanceOf(owner.address)).to.equal(initialSupply * unit);

    await expect(greeter.setGreeting("Good morning"))
      .to.emit(greeter, "GreetingChanged")
      .withArgs(owner.address, "Good morning");
    expect(await greeter.greeting()).to.equal("Good morning");
  });

  it("does not let an unlisted node change the greeting", async function () {
    const [, alice] = await ethers.getSigners();
    const greeter = await deployGreeter();

    await expect(greeter.connect(alice).setGreeting("Unauthorized"))
      .to.be.revertedWithCustomError(greeter, "UnauthorizedGreetingEditor")
      .withArgs(alice.address);
  });

  it("lets the owner add a node that can change the greeting", async function () {
    const [, alice] = await ethers.getSigners();
    const greeter = await deployGreeter();

    await expect(greeter.allowNode(alice.address))
      .to.emit(greeter, "NodePermissionChanged")
      .withArgs(alice.address, true);
    expect(await greeter.isAllowedNode(alice.address)).to.equal(true);
    expect(await greeter.getAllowedNodes()).to.deep.equal([alice.address]);

    await greeter.connect(alice).setGreeting("Updated by Alice");
    expect(await greeter.greeting()).to.equal("Updated by Alice");
  });

  it("allows only the owner to manage the node list and can revoke access", async function () {
    const [, alice, bob] = await ethers.getSigners();
    const greeter = await deployGreeter();

    await expect(greeter.connect(alice).allowNode(bob.address))
      .to.be.revertedWithCustomError(greeter, "NotOwner")
      .withArgs(alice.address);

    await greeter.allowNode(alice.address);
    await expect(greeter.removeNode(alice.address))
      .to.emit(greeter, "NodePermissionChanged")
      .withArgs(alice.address, false);
    expect(await greeter.getAllowedNodes()).to.deep.equal([]);

    await expect(greeter.connect(alice).setGreeting("No access anymore"))
      .to.be.revertedWithCustomError(greeter, "UnauthorizedGreetingEditor")
      .withArgs(alice.address);
  });

  it("transfers ERC-20 tokens and updates balances", async function () {
    const [owner, alice] = await ethers.getSigners();
    const greeter = await deployGreeter();
    const amount = 25n * unit;

    await expect(greeter.transfer(alice.address, amount))
      .to.emit(greeter, "Transfer")
      .withArgs(owner.address, alice.address, amount);
    expect(await greeter.balanceOf(owner.address)).to.equal(initialSupply * unit - amount);
    expect(await greeter.balanceOf(alice.address)).to.equal(amount);
  });

  it("uses approve and transferFrom while reducing a finite allowance", async function () {
    const [owner, alice, bob] = await ethers.getSigners();
    const greeter = await deployGreeter();
    const approvedAmount = 40n * unit;
    const spentAmount = 15n * unit;

    await expect(greeter.approve(alice.address, approvedAmount))
      .to.emit(greeter, "Approval")
      .withArgs(owner.address, alice.address, approvedAmount);
    expect(await greeter.allowance(owner.address, alice.address)).to.equal(approvedAmount);

    await expect(greeter.connect(alice).transferFrom(owner.address, bob.address, spentAmount))
      .to.emit(greeter, "Transfer")
      .withArgs(owner.address, bob.address, spentAmount);
    expect(await greeter.balanceOf(bob.address)).to.equal(spentAmount);
    expect(await greeter.allowance(owner.address, alice.address)).to.equal(approvedAmount - spentAmount);
  });

  it("rejects transfers without enough balance or allowance", async function () {
    const [owner, alice, bob] = await ethers.getSigners();
    const greeter = await deployGreeter();

    await expect(greeter.connect(alice).transfer(bob.address, 1n))
      .to.be.revertedWithCustomError(greeter, "ERC20InsufficientBalance")
      .withArgs(alice.address, 0n, 1n);

    await expect(greeter.connect(alice).transferFrom(owner.address, bob.address, 1n))
      .to.be.revertedWithCustomError(greeter, "ERC20InsufficientAllowance")
      .withArgs(alice.address, 0n, 1n);
  });
});
