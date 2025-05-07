// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";
import {ScriptBase} from "./ScriptBase.sol";
import {SuperlendSiloV2Strategy} from "../src/silo/SiloV2Strategy.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract SiloV2SuperlendScript is ScriptBase {
    uint256 chainId = chainIds.SONIC;

    uint256 deployerPvtKey;
    address deployerAddress;

    SuperlendSiloV2Strategy silo;

    function setUp() public override {
        super.setUp();
        vm.createSelectFork("sonic");

        deployerPvtKey = vm.envUint("PRIVATE_KEY");
        deployerAddress = vm.addr(deployerPvtKey);
    }

    function run() public {
        vm.startBroadcast(deployerPvtKey);

        address siloStrategyImplementation = address(
            new SuperlendSiloV2Strategy()
        );

        silo = SuperlendSiloV2Strategy(
            address(
                new TransparentUpgradeableProxy(
                    siloStrategyImplementation,
                    address(this),
                    ""
                )
            )
        );

        silo.initialize(
            "Superlend SiloV2 USDC", // change this with name `Superlend SiloV2 <silo name>`
            "slSilo USDC", // change this with symbol `slSilo <silo symbol>`
            usdc[chainId],
            siloVault[chainId]
        );

        console.log("silo vault address", address(silo));
        vm.stopBroadcast();
    }
}
