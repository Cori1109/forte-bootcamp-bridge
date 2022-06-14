// scripts/index.js
module.exports = async function main (callback) {
  try {

    const NftBridgeToken = artifacts.require('NftBridgeToken');
    const nft = await NftBridgeToken.deployed();

    await nft.safeMint("0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1", 1, "https://a6cpxhuevpzgqtyj5eotbjmqenufvktr5ohmosj3awdpbdw7kw6a.arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVb");

    const owner = await nft.ownerOf(1)
    console.log(owner)

    const url = await nft.tokenURI(1)
    console.log(url)

  } catch (error) {
    console.error(error);
    callback(1);
  }
};
