// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";

contract DeployMyTokenScript is Script {
    function run() external {
        // load variables from envinronment
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address contractOwner = vm.envAddress("CONTRACT_OWNER_ADDRESS");
        // deploying the contract
        vm.startBroadcast(deployerPrivateKey);
        MyToken token = new MyToken(contractOwner);
        vm.stopBroadcast();
    }
}
