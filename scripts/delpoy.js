const hre = require("hardhat");
const maxSupply = 10000000;//10M total Token Supply

async function main() {
  const Token = await hre.ethers.getContractFactory("Token");
  const token = await Token.deploy("Akshay","AKKI",maxSupply);
  await token.deployed();
  console.log("Token deployed to:", token.address);

  const ICO = await hre.ethers.getContractFactory("ICO");
  const ico = await ICO.deploy(token.address,
    604800,//1 Week duration
    1000000,//1M available Token for ICO
    ethers.utils.parseUnits("2",3), //Price of 1 Token in DIA Token
    50,// minimum purchase of 50 DIA
    100// maximum purchase of 100 DIA
    );
  await ico.deployed();
  console.log("ICO Deployed to:",ico.address);

  await token.updateAdmin(ico.address);
  await ico.start();

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
