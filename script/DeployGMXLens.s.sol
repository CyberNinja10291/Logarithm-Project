// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {GMXLens} from "../src/GMXLens.sol";

contract DeployGMXLensScript is Script {
    function run() external {
        // load variables from envinronment
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address contractOwner = vm.envAddress("CONTRACT_OWNER_ADDRESS");
        // deploying the contract
        vm.startBroadcast(deployerPrivateKey);
        GMXLens gmxLens = new GMXLens(contractOwner);


        // Address in the Arbitrum
        address dataStore = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
        address reader = 0xf60becbba223EEA9495Da3f606753867eC10d139;
        address oracle = 0xeDA605e77aFB949d2856Fb0b1109dDB563218cd1;
        address chainlinkOracle = 0x0aD138107cFc0dbd153407249dCeF6e622D50c2c;


        gmxLens.setConfig(dataStore, reader, oracle, chainlinkOracle);
        vm.stopBroadcast();
    }
}
