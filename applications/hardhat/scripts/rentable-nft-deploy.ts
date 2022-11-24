import { ethers } from "hardhat";

async function main() {


  const token_name = "Test"
  const token_symbol = "TEST"

  // Contracts are deployed using the first signer/account by default
  const [owner, otherAccount] = await ethers.getSigners();

  const Rental = await ethers.getContractFactory("ERC4907");
  const rental = await Rental.deploy(token_name, token_symbol);

  console.log(`Rentable NFT deployed to ${rental.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
