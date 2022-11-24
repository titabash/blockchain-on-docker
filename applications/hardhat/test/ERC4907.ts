import { time, loadFixture, mine } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

const sleep = (waitTime: number) => new Promise( resolve => setTimeout(resolve, waitTime) );

describe("ERC4907", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployRentableNFTFixture() {
    const token_name = "Test"
    const token_symbol = "TEST"

    // Contracts are deployed using the first signer/account by default
    const [owner, addr1, addr2] = await ethers.getSigners();

    const Rental = await ethers.getContractFactory("ERC4907");
    const rental = await Rental.deploy(token_name, token_symbol);

    return { rental, owner, addr1, addr2};
  }

  describe("Normal NFT Test", function () {
    it("Mint NFT", async function () {
      const { rental, owner } = await loadFixture(deployRentableNFTFixture);
      await rental.mint(1)
      expect(await rental.ownerOf(0)).to.equal(owner.address);
    });

    it("Transfer NFT", async function () {
      const { rental, owner, addr1 } = await loadFixture(deployRentableNFTFixture);
      await rental.mint(1)
      await rental.transferFrom(owner.address, addr1.address, 0)
      expect(await rental.ownerOf(0)).to.equal(addr1.address);
    });
  });

  describe("Rentable NFT Test", function () {
    it("Rental NFT", async function () {
      const { rental, owner, addr1 } = await loadFixture(deployRentableNFTFixture);
      await rental.mint(1)
      let date = new Date() ;
      let expireTime = date.getTime() + 10000;
      await rental.setUser(0, addr1.address, expireTime)
      expect(await rental.ownerOf(0)).to.equal(owner.address);
      expect(await rental.userOf(0)).to.equal(addr1.address);
    });

    it("Restrict transfer", async function () {
      const { rental, owner, addr1, addr2} = await loadFixture(deployRentableNFTFixture);
      await rental.mint(1)
      let date = new Date();
      console.log(date.getTime())
      date.setSeconds(date.getSeconds() + 10);
      console.log(date.getTime())

      await rental.setUser(0, addr1.address, date.getTime())
      expect(await rental.ownerOf(0)).to.equal(owner.address);
      expect(await rental.userOf(0)).to.equal(addr1.address);

      try {
        await rental.transferFrom(owner.address, addr2.address, 0)
      } catch (error) {
        console.error("コントラクト失敗")
      }
      expect(await rental.ownerOf(0)).to.equal(owner.address);
      expect(await rental.userOf(0)).to.equal(addr1.address);

      await time.increaseTo(date.getTime() + 1000);
      await mine(1000)

      console.log(await rental.userOf(0))

      await rental.transferFrom(owner.address, addr1.address, 0)

      expect(await rental.ownerOf(0)).to.equal(addr1.address);

    });
  });
});
