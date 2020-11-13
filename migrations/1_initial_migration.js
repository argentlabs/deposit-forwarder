const ForwarderFactory = artifacts.require("ForwarderFactory");
const MinimalForwarderFactory = artifacts.require("MinimalForwarderFactory");

module.exports = function (deployer) {
  deployer.deploy(ForwarderFactory);
  deployer.deploy(MinimalForwarderFactory);
};
