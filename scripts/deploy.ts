import hre from "hardhat";

async function main() {
  // @ts-ignore
  const helloWorld = await hre.ethers.deployContract("HelloWorld", ["Hello, World!"]);
  // @ts-ignore
  await helloWorld.waitForDeployment();

  // @ts-ignore
  const address = await helloWorld.getAddress();
  console.log(`Smart Contract deployed to: ${address}`);

  // @ts-ignore
  const message = await helloWorld.message();
  console.log(`Initial message: "${message}"`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});