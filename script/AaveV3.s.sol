// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";
import {ScriptBase} from "./ScriptBase.sol";
import {SuperlendAaveV3Strategy} from "../src/aave/AaveV3Strategy.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract AaveV3SuperlendScript is ScriptBase {
    uint256 chainId = chainIds.SONIC;

    uint256 deployerPvtKey;
    address deployerAddress;

    SuperlendAaveV3Strategy aave;

    function setUp() public override {
        super.setUp();
        vm.createSelectFork("sonic");

        deployerPvtKey = vm.envUint("PRIVATE_KEY");
        deployerAddress = vm.addr(deployerPvtKey);
    }

    function run() public {
        vm.startBroadcast(deployerPvtKey);

        address aaveStrategyImplementation = address(
            new SuperlendAaveV3Strategy()
        );

        aave = SuperlendAaveV3Strategy(
            address(
                new TransparentUpgradeableProxy(
                    aaveStrategyImplementation,
                    address(this),
                    ""
                )
            )
        );

        aave.initialize(
            "Superlend AaveV3 USDC",
            "slAaveUSDC",
            usdc[chainId],
            pool[chainId]
        );

        console.log("aave vault address", address(aave));
        vm.stopBroadcast();
    }
}
