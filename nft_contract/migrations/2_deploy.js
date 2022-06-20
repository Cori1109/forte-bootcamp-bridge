// migrations/2_deploy.js
const NftBridgeToken = artifacts.require('NftBridgeToken');

module.exports = async function (deployer) {
  await deployer.deploy(NftBridgeToken);
};
