const ForwarderFactory = artifacts.require("PermanentForwarderFactory");
const Forwarder = artifacts.require("PermanentForwarder");

const ETH_TOKEN = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

contract("Test Permanent Forwarder Factory", async accounts => {

    it("should deploy and forward in 2 transactions", async () => {
        // create factory
        let factory = await ForwarderFactory.new();
        // get forwarder address
        let forwarder = await factory.getForwarder(accounts[1]);
        console.log("Forwarder at: " + forwarder);
        // send eth to forwarder
        await web3.eth.sendTransaction({from: accounts[1], to: forwarder, value: 50000000});
        let balance = await web3.eth.getBalance(forwarder);
        assert.equal(balance.valueOf(), 50000000, "should have received eth");
        // deploy forwarder
        let tx = await factory.deployForwarder(accounts[1]);
        console.log("GAS used 1: " + tx.receipt.gasUsed )
        let deployedForwarder = await Forwarder.at(forwarder);
        // forward eth
        tx = await deployedForwarder.forward(ETH_TOKEN);
        balance = await web3.eth.getBalance(forwarder);
        assert.equal(balance.valueOf(), 0, "should have forwarded eth");
        console.log("GAS used 2: " + tx.receipt.gasUsed )
    });
});