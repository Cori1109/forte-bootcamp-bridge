// scripts/index.js
module.exports = async function main (callback) {
  try {

    const NftBridgeToken = artifacts.require('NftBridgeToken');
    const nft = await NftBridgeToken.deployed();

    await nft.safeMint("0xc354a878bcD24eBd597732CBEf7a4fc925653c9B", 1, "https://a6cpxhuevpzgqtyj5eotbjmqenufvktr5ohmosj3awdpbdw7kw6a.arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVb");

    const owner = await nft.ownerOf(1)
    console.log(owner)

    const url = await nft.tokenURI(1)
    console.log(url)

    await nft.safeTransferFrom("0xc354a878bcD24eBd597732CBEf7a4fc925653c9B", "0x89D66c0d43b9fC762BA07DCB16f05B8b5e0d5826", 1)

    const owner2 = await nft.ownerOf(1)
    console.log(owner2)

  } catch (error) {
    console.error(error);
    callback(1);
  }
};
