// scripts/deploy.js

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const MaxSupply = 150; // Ejemplo de cantidad máxima
  const MaxPerWallet = 1; // Ejemplo de máximo por wallet

  const Badge = await ethers.getContractFactory("BB11");
  const badge = await Badge.deploy(MaxSupply, MaxPerWallet);

  console.log("BB11 deployed to:", badge.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});