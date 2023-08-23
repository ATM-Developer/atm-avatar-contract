// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  //const luca = 0x51E6Ac1533032E72e92094867fD5921e3ea1bfa0; //mian net
  const luca = "0xD7a1cA21D73ff98Cc64A81153eD8eF89C2a1EfEF"; //test net
  const price = 10000;
  const limit = 2000;

  console.log("\n\n\n########### deploy contracts ################\n\n\n");
  const avatar = await hre.ethers.getContractFactory("Avatar");
  const Avatar = await avatar.deploy("Avatar NFT Test","AVT",luca, price, limit);
  console.log(`Avatar NFT Contract deployed, address :${Avatar.address}`);

  const avatarLinkPorxy = await hre.ethers.getContractFactory("AvatarLinkProxy");
  const AvatarLinkPorxy = await avatarLinkPorxy.deploy(Avatar.address);
  console.log(`AvatarLinkPorxy Contract deployed, address :${AvatarLinkPorxy.address}, logicAddress : ${AvatarLinkPorxy.logic()}`);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
