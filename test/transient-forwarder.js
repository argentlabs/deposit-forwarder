const ForwarderFactory = artifacts.require("TransientForwarderFactory");

const ETH_TOKEN = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";

contract("Test Transient Forwarder Factory", async accounts => {

    it("should deploy, forward and destruct in 1 transaction", async () => {
        // create factory
        let factory = await ForwarderFactory.new();
        // get forwarder address
        let forwarder = await factory.getForwarder(accounts[1]);
        console.log("Forwarder at: " + forwarder);
        // send eth to forwarder
        await web3.eth.sendTransaction({from: accounts[1], to: forwarder, value: 50000000});
        let balance = await web3.eth.getBalance(forwarder);
        assert.equal(balance.valueOf(), 50000000, "should have received eth");
        // forward eth
        let tx = await factory.forward(accounts[1], ETH_TOKEN);
        balance = await web3.eth.getBalance(forwarder);
        assert.equal(balance.valueOf(), 0, "should have forwarded eth");
        console.log("GAS used: " + tx.receipt.gasUsed )
    });
});