import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("BinaryConverter", function () {
  it("converts 25901 into two groups of 8 bits", async function () {
    const converter = await ethers.deployContract("BinaryConverter");

    expect(await converter.numberToBinary(25901n)).to.equal("01100101 00101101");
  });

  it("adds leading zeroes to fill a byte", async function () {
    const converter = await ethers.deployContract("BinaryConverter");

    expect(await converter.numberToBinary(5n)).to.equal("00000101");
  });

  it("uses several byte groups when necessary", async function () {
    const converter = await ethers.deployContract("BinaryConverter");

    expect(await converter.numberToBinary(256n)).to.equal("00000001 00000000");
  });

  it("represents zero as one byte", async function () {
    const converter = await ethers.deployContract("BinaryConverter");

    expect(await converter.numberToBinary(0n)).to.equal("00000000");
  });
});
