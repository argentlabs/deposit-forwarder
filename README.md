# deposit-forwarder

Proof of concept to explore and benchmark how to deposit funds from a CEX to a L2 wallet without the need to have a L1 wallet.

We consider 3 options:

**The permanent forwarder:** 

- The counterfactual address of a forwarder is obtained by calling `factory.getForwarder(_wallet)`
- The forwarder is a minimal-proxy delegating to a fixed implementation (EIP 1167)
- The forwarder is deployed separately after the first deposit by calling `factory.deployForwarder(_wallet)`
- For each deposit the funds can be forwarded by calling the `forwarder.forward(_token)`
- deployment: 90709 gas, forward ETH: 30814 gas

**The transient forwarder:**

- The counterfactual address of a forwarder is obtained by calling `factory.getForwarder(_wallet)`
- The forwarder is a minimal-proxy delegating to a fixed implementation (EIP 1167)
- For each deposit the forwarder is deployed, the funds are forwarded and the forwarder is destructed in a single transaction by calling `factory.forward(_wallet, _token)`
- forward ETH: 58901 gas

**The flexible forwarder:**

- The counterfactual address of a forwarder is obtained by calling `factory.getForwarder(_wallet)`
- The forwarder can have a different implementation on every transaction and e.g. target a different L2
- For each deposit the forwarder is deployed, the funds are forwarded and the forwarder is destructed in a single transaction by calling `factory.forward(_wallet, _token)`
- forward ETH: 115708 gas

NOTE: If needed the transient forwarder and flexible forwarder patterns can be combined to enable 1 forwarder address per user capable to forward funds to multiple L2 at reduced cost.
