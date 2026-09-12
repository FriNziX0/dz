import hre from "hardhat";
const { ethers } = hre as any;

async function main() {
    const [deployer] = await ethers.getSigners();
    if (!deployer) {
        console.error("Помилка: Гаманець не підключено!");
        return;
    }
    console.log("Авторизовано гаманець:", deployer.address);

    const contractAddress = "0xc9e905EA27b6D2C2651Aec1a39B64E4BAf762631";
    const HelloWorld = await ethers.getContractFactory("HelloWorld");
    const helloWorld = HelloWorld.attach(contractAddress);

    console.log("Отримання даних з контракту...");
    const message = await helloWorld.message();

    console.log("Поточне повідомлення у контракті:", message);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});