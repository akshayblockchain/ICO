//const { inputToConfig } = require("@ethereum-waffle/compiler");
const { expect } = require("chai");
//const { ethers } = require("hardhat");

let owner,addr1;
let token;
let ico;

beforeEach(async()=>{
  [owner,addr1]= await ethers.getSigners();
  const Token = await ethers.getContractFactory("Token");
  token = await Token.deploy("Akshay","AKKI",10000000);
  console.log(token.address);
  const ICO = await ethers.getContractFactory("ICO");
  ico = await ICO.deploy(token.address,604800,1000000,ethers.utils.parseUnits("2",3),50,100);
  console.log(ico.address);

});

describe("Token",function(){
  it("Update Token contract Admin to ICO address",async()=>{
    await token.updateAdmin(ico.address);
    expect(await token.admin()).to.equal(await ico.address);
  });
  it("Max Supply",async()=>{
    expect(await token.maxSupply()).to.equal(10000000);
  });
  it("Mint function",async()=>{
    await token.mint(addr1.address,50);
    expect(await token.totalSupply()).to.equal(50);
  });
});

describe("ICO",function(){
  it("All Variables",async()=>{
   expect(await ico.end()).to.equal(0); 
   expect(await ico.duration()).to.equal(604800); 
   expect(await ico.price()).to.equal(ethers.utils.parseUnits("2",3)); 
   expect(await ico.minPurchase()).to.equal(50); 
   expect(await ico.maxPurchase()).to.equal(100); 
   expect(await ico.availableToken()).to.equal(1000000);
  });
  it("Buy function",async()=>{
    await token.updateAdmin(ico.address);
    await ico.start();
    // await ico.buy(50); //  error for calling dai contract
    // expect(await token.totalSupply()).to.equal(50);
  });
});
