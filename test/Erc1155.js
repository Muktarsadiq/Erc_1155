const { expect } = require("chai");

describe("YvesToken contract", function () {
  let yvesToken;
  let owner;
  let addr1;
  let addr2;

  const uri = "https://ipfs.io/ipfs/Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";

  beforeEach(async function () {
    const YvesToken = await ethers.getContractFactory('YvesToken');
    [owner, addr1, addr2] = await ethers.getSigners();

    yvesToken = await YvesToken.deploy();
    await yvesToken.deployed();
  });

  it("should deploy and set the URI correctly", async function () {
    expect(await yvesToken.uri(0)).to.equal(uri);
  });

  it("should allow minting by the owner", async function () {
    await yvesToken.mint(0, 1);
    const balance = await yvesToken.balanceOf(owner.address, 0);
    expect(balance).to.equal(1);
  });

  it("should not allow minting if mintOpen is false", async function () {
    await yvesToken.editMint(false, true);
    await expect(yvesToken.mint(0, 1)).to.be.revertedWith("sorry the mint function is closed");
  });

  it("should allow minting for addresses on the allow list", async function () {
    await yvesToken.addToAllowlist(addr1.address);
    await yvesToken.allowListMint(0, 1, { value: ethers.utils.parseEther("0.005") });
    const balance = await yvesToken.balanceOf(addr1.address, 0);
    expect(balance).to.equal(1);
  });

  it("should not allow minting for addresses not on the allow list", async function () {
    await yvesToken.editMint(false, true);
    await expect(yvesToken.allowListMint(0, 1, { value: ethers.utils.parseEther("0.005") }))
      .to.be.revertedWith("You are not on the Allow List");
  });

  it("should set the URI correctly", async function () {
    const newURI = "https://example.com/token/";
    await yvesToken.setURI(newURI);
    expect(await yvesToken.uri(0)).to.equal(newURI + "0.json");
  });

  it("should set the allow list correctly", async function () {
    await yvesToken.setAllowList([addr1.address, addr2.address]);
    expect(await yvesToken.allowList(addr1.address)).to.be.true;
    expect(await yvesToken.allowList(addr2.address)).to.be.true;
  });

  it("should allow the owner to withdraw funds", async function () {
    const value = ethers.utils.parseEther("1.0");
    await yvesToken.mint(0, 1, { value });
    const ownerBalanceBefore = await ethers.provider.getBalance(owner.address);
    await yvesToken.withdraw();
    const ownerBalanceAfter = await ethers.provider.getBalance(owner.address);
    expect(ownerBalanceAfter.sub(ownerBalanceBefore)).to.equal(value);
  });

  it("should revert if a non-owner tries to withdraw funds", async function () {
    await expect(yvesToken.connect(addr1).withdraw()).to.be.revertedWith("Ownable: caller is not the owner");
  });

  // Add more unit tests as needed
});
