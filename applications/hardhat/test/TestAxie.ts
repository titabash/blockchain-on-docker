import { time, loadFixture, mine } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("TestAxie", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployRentableNFTFixture() {
    const token_name = "TestAxie"
    const token_symbol = "TAX"

    // Contracts are deployed using the first signer/account by default
    const [owner, addr1, addr2] = await ethers.getSigners();

    const Rental = await ethers.getContractFactory("TestAxie");
    const rental = await Rental.deploy(token_name, token_symbol);

    return { rental, owner, addr1, addr2};
  }

  describe("Normal NFT Test", function () {
    it("Mint NFT", async function () {
      const { rental, owner } = await loadFixture(deployRentableNFTFixture);
      await rental.mint()
      expect(await rental.ownerOf(0)).to.equal(owner.address);
    });

    it("Transfer NFT", async function () {
      const { rental, owner, addr1 } = await loadFixture(deployRentableNFTFixture);
      await rental.mint()
      await rental.transferFrom(owner.address, addr1.address, 0)
      expect(await rental.ownerOf(0)).to.equal(addr1.address);
    });
  });

  describe("Rentable NFT Test", function () {
    it("Rental NFT", async function () {
      const { rental, owner, addr1 } = await loadFixture(deployRentableNFTFixture);
      await rental.mint()
      await rental.setRentalFee(0, ethers.utils.parseEther("1000"))
      let date = new Date() ;
      let expireTime = date.getTime() + 10000;
      console.log(await ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
      await rental.setScholar(0, addr1.address, expireTime, 10, { value: ethers.utils.parseEther("1000") })
      console.log(await ethers.utils.formatEther(await ethers.provider.getBalance(owner.address)));
      expect(await rental.ownerOf(0)).to.equal(owner.address);
      expect(await rental.userOf(0)).to.equal(addr1.address);
    });

    it("Restrict transfer", async function () {
      const { rental, owner, addr1, addr2} = await loadFixture(deployRentableNFTFixture);
      await rental.mint()
      await rental.setRentalFee(0, ethers.utils.parseEther("1000"))
      let date = new Date();
      console.log(date.getTime())
      date.setSeconds(date.getSeconds() + 10);
      console.log(date.getTime())

      await rental.setScholar(0, addr1.address, date.getTime(), 10)
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

    it("Winning battle", async function () {
      const { rental, owner, addr1, addr2 } = await loadFixture(deployRentableNFTFixture);
      await rental.mint()
      await rental.transferFrom(owner.address, addr2.address, 0)
      await rental.connect(addr2).setRentalFee(0, ethers.utils.parseEther("1"))
      let date = new Date();
      let expireTime = date.getTime() + 10000;
      await rental.connect(addr1).setScholar(0, addr1.address, expireTime, 10, {value: ethers.utils.parseEther("1") })
      expect(await rental.ownerOf(0)).to.equal(addr2.address);
      expect(await rental.userOf(0)).to.equal(addr1.address);
      let beforeBalance = await ethers.utils.formatEther(await ethers.provider.getBalance(addr2.address));
      console.log(beforeBalance);
      await rental.connect(owner).win(0, { value: ethers.utils.parseEther("1") })
      let afterBalance = await ethers.utils.formatEther(await ethers.provider.getBalance(addr2.address));
      console.log(afterBalance);
      expect(Number(afterBalance) - Number(beforeBalance)).to.equal(0.8999999999996362); // ガス代で一部消失
    });
  });
});
