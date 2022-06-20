const { expect } = require('chai');

const Nft = artifacts.require('NftBridgeToken');

contract('NftBridgeToken', function () {
  beforeEach(async function () {
    this.nft = await Nft.new();
  });

  // Test case
  it('mint token', async function () {

    const to = "0xc354a878bcD24eBd597732CBEf7a4fc925653c9B";
    const token_id = 1;
    const url = "https://a6cpxhuevpzgqtyj5eotbjmqenufvktr5ohmosj3awdpbdw7kw6a.arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVb";

    await this.nft.safeMint(to,token_id,url);

    const owner = await this.nft.ownerOf(1);
    expect(owner).to.equal(to);

    const uri = await this.nft.tokenURI(1);
    expect(uri).to.equal(url);
  });
});
