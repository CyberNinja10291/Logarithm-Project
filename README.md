## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployGMXLens.s.sol:DeployGMXLensScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell

$ forge test
$ forge compile
$ forge --help
```

### Contract Address in Abitrum
```
    dataStore: 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
    reader: 0xf60becbba223EEA9495Da3f606753867eC10d139;
    gmxOracle: 0xeDA605e77aFB949d2856Fb0b1109dDB563218cd1;
    chainlinkOracle: 0x0aD138107cFc0dbd153407249dCeF6e622D50c2c;
```