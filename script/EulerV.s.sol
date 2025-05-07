// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";
import {ScriptBase} from "./ScriptBase.sol";
import {SuperlendEulerV2Strategy} from "../src/euler/EulerV2Strategy.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract EulerV2SuperlendScript is ScriptBase {
    uint256 chainId = chainIds.SONIC;

    uint256 deployerPvtKey;
    address deployerAddress;

    SuperlendEulerV2Strategy euler;

    function setUp() public override {
        super.setUp();
        vm.createSelectFork("sonic");

        deployerPvtKey = vm.envUint("PRIVATE_KEY");
        deployerAddress = vm.addr(deployerPvtKey);
    }

    function run() public {
        vm.startBroadcast(deployerPvtKey);

        address eulerStrategyImplementation = address(
            new SuperlendEulerV2Strategy()
        );

        euler = SuperlendEulerV2Strategy(
            address(
                new TransparentUpgradeableProxy(
                    eulerStrategyImplementation,
                    address(this),
                    ""
                )
            )
        );

        euler.initialize(
            "Superlend Euler eUSDC.e-1",
            "slEulerUSDC.e-1",
            usdc[chainId],
            eulerVault[chainId]
        );

        console.log("aave vault address", address(euler));
        vm.stopBroadcast();
    }
}
