import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("AddressConverter", function () {
  it("converts a valid string address into an address", async function () {
    const converter = await ethers.deployContract("AddressConverter");
    const textAddress = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";

    expect(await converter.stringToAddress(textAddress)).to.equal(
      ethers.getAddress(textAddress),
    );
  });

  it("accepts uppercase hexadecimal characters and the 0X prefix", async function () {
    const converter = await ethers.deployContract("AddressConverter");
    const textAddress = "0X5FBDB2315678AFECB367F032D93F642F64180AA3";

    expect(await converter.stringToAddress(textAddress)).to.equal(
      "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    );
  });

  it("reverts when the address string has an invalid length", async function () {
    const converter = await ethers.deployContract("AddressConverter");

    await expect(converter.stringToAddress("0x1234"))
      .to.be.revertedWithCustomError(converter, "InvalidAddressLength")
      .withArgs(6n);
  });

  it("reverts when the address string has an invalid prefix", async function () {
    const converter = await ethers.deployContract("AddressConverter");
    const invalidAddress = "zz5FbDB2315678afecb367f032d93F642f64180aa3";

    await expect(converter.stringToAddress(invalidAddress)).to.be.revertedWithCustomError(
      converter,
      "InvalidAddressPrefix",
    );
  });

  it("reverts when the address string contains a non-hexadecimal character", async function () {
    const converter = await ethers.deployContract("AddressConverter");
    const invalidAddress = "0x5FbDB2315678afecb367f032d93F642f64180aaG";

    await expect(converter.stringToAddress(invalidAddress))
      .to.be.revertedWithCustomError(converter, "InvalidHexCharacter")
      .withArgs("0x47");
  });
});
