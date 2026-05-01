const { ethers, network } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(
    `Deploying OpenAccord to ${network.name} with account: ${deployer.address}`,
  );

  const balance = await ethers.provider.getBalance(deployer.address);
  console.log(`Account balance: ${ethers.formatEther(balance)} ETH`);

  // devAddress receives optional contributions — set to deployer or a multisig
  const devAddress = process.env.DEV_ADDRESS || deployer.address;
  console.log(`Dev address: ${devAddress}`);

  const OpenAccord = await ethers.getContractFactory("OpenAccord");
  const contract = await OpenAccord.deploy(devAddress);
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log(`OpenAccord deployed to: ${address}`);
  console.log(`\nVerify with:`);
  console.log(
    `npx hardhat verify --network ${network.name} ${address} "${devAddress}"`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
