// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import "../src/CogniCraft.sol";
import "@oz/proxy/transparent/ProxyAdmin.sol";
import "@oz/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployCogniCraft is Script {
    function run() external {
        vm.startBroadcast();

        CogniCraft cogniCraft = new CogniCraft();

        ProxyAdmin proxyAdmin = new ProxyAdmin();

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(cogniCraft),
            address(proxyAdmin),
            ""
        );

        CogniCraft(address(proxy)).initialize();

        vm.stopBroadcast();
    }
}
