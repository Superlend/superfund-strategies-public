// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";
import {ScriptBase} from "../ScriptBase.sol";
import {IEulerEarn} from "euler-earn/src/interface/IEulerEarn.sol";
import {SuperlendAaveV3Strategy} from "../../src/aave/AaveV3Strategy.sol";
import {SuperlendEulerV2Strategy} from "../../src/euler/EulerV2Strategy.sol";

contract SonicVaultTxn is ScriptBase {
    uint256 deployerPvtKey;
    address deployerAddress;

    function setUp() public override {
        super.setUp();
        vm.createSelectFork("sonic");

        deployerPvtKey = vm.envUint("PRIVATE_KEY");
        deployerAddress = vm.addr(deployerPvtKey);
    }

    function run() public {
        vm.startBroadcast(deployerPvtKey);

        IEulerEarn vault = IEulerEarn(
            0x96328cd6fBCc3adC8bee58523Bbc67aBF38f8124
        );

        SuperlendAaveV3Strategy aaveStrategy;
        SuperlendEulerV2Strategy eulerStrategy1;
        SuperlendEulerV2Strategy eulerStrategy2;
        aaveStrategy = SuperlendAaveV3Strategy(
            0x7342c3387EfBbcc9fa505027bd1fDB0093e6E8bA
        );
        eulerStrategy1 = SuperlendEulerV2Strategy(
            0x417B12320601D59A548b67ce08b15F7c4bF4fe4d
        );
        eulerStrategy2 = SuperlendEulerV2Strategy(
            0x5001f8Ca9fc7809D13854885E419D11Da12df8AF
        );

        address[] memory strats = new address[](3);
        strats[2] = address(aaveStrategy);
        strats[1] = address(eulerStrategy1);
        strats[0] = address(eulerStrategy2);

        vault.rebalance(strats);

        vm.stopBroadcast();
    }
}
