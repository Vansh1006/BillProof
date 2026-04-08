// scripts/deploy.js
// Run: npx hardhat run scripts/deploy.js --network amoy
//
// Prerequisites:
//   npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox dotenv
//   Create .env with: PRIVATE_KEY=0x... and POLYGONSCAN_API_KEY=...
//
// hardhat.config.js minimum setup:
// ─────────────────────────────────────────────────────────────────────────────
// require("@nomicfoundation/hardhat-toolbox");
// require("dotenv").config();
// module.exports = {
//   solidity: "0.8.20",
//   networks: {
//     amoy: {                                  // Polygon testnet
//       url: "https://rpc-amoy.polygon.technology",
//       chainId: 80002,
//       accounts: [process.env.PRIVATE_KEY],
//     },
//     polygon: {                               // Polygon mainnet
//       url: "https://polygon-rpc.com",
//       chainId: 137,
//       accounts: [process.env.PRIVATE_KEY],
//     },
//   },
//   etherscan: { apiKey: { polygonAmoy: process.env.POLYGONSCAN_API_KEY } },
// };
// ─────────────────────────────────────────────────────────────────────────────

const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "MATIC");

  const BillProof = await ethers.getContractFactory("BillProof");
  const contract  = await BillProof.deploy();
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log("\n✅ BillProof deployed to:", address);
  console.log("\nAdd this to your frontend index.html:");
  console.log(`  const CONTRACT_ADDRESS = "${address}";`);
  console.log("\nVerify on Polygonscan (after deploy):");
  console.log(`  npx hardhat verify --network amoy ${address}`);
}

main().catch((err) => { console.error(err); process.exit(1); });
