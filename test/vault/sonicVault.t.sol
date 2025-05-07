// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import {TestBase} from "../helpers/TestBase.sol";
import {IEulerEarn} from "euler-earn/src/interface/IEulerEarn.sol";
import {SuperlendAaveV3Strategy} from "../../src/aave/AaveV3Strategy.sol";
import {SuperlendEulerV2Strategy} from "../../src/euler/EulerV2Strategy.sol";

contract SonicVault is TestBase {
    uint256 chainId = chainIds.SONIC;
    IEulerEarn vault;

    address tokenWhale;
    address user1;
    address user2;

    SuperlendAaveV3Strategy aaveStrategy;
    SuperlendEulerV2Strategy eulerStrategy1;
    SuperlendEulerV2Strategy eulerStrategy2;

    address admin;

    function setUp() public override {
        super.setUp();

        aaveStrategy = SuperlendAaveV3Strategy(
            0x7342c3387EfBbcc9fa505027bd1fDB0093e6E8bA
        );
        eulerStrategy1 = SuperlendEulerV2Strategy(
            0x417B12320601D59A548b67ce08b15F7c4bF4fe4d
        );
        eulerStrategy2 = SuperlendEulerV2Strategy(
            0x5001f8Ca9fc7809D13854885E419D11Da12df8AF
        );
        vault = IEulerEarn(0x96328cd6fBCc3adC8bee58523Bbc67aBF38f8124);

        tokenWhale = usdcWhale[chainId];
        admin = 0xad04EFa44DF63b0B47CFD24b4b009D3b25473B0b;

        user1 = vm.addr(0x123);
        user2 = vm.addr(0x567);

        vm.createSelectFork("sonic");
    }

    function test_SonicReadStrategies() public {
        IEulerEarn.Strategy memory aaveStrat = vault.getStrategy(
            address(aaveStrategy)
        );

        console.log("Aave strategy");
        console.log("allocated ", aaveStrat.allocated);
        console.log("allocation points ", aaveStrat.allocationPoints);
        console.log("status ", uint256(aaveStrat.status));

        IEulerEarn.Strategy memory euler1Strat = vault.getStrategy(
            address(eulerStrategy1)
        );

        console.log("Euler 1 strategy");
        console.log("allocated ", euler1Strat.allocated);
        console.log("allocation points ", euler1Strat.allocationPoints);
        console.log("status ", uint256(euler1Strat.status));

        IEulerEarn.Strategy memory euler2Strat = vault.getStrategy(
            address(eulerStrategy2)
        );

        console.log("Euler 2 strategy");
        console.log("allocated ", euler2Strat.allocated);
        console.log("allocation points ", euler2Strat.allocationPoints);
        console.log("status ", uint256(euler2Strat.status));

        IEulerEarn.Strategy memory cashReserve = vault.getStrategy(address(0));

        console.log("Cash reserve");
        console.log("allocated ", cashReserve.allocated);
        console.log("allocation points ", cashReserve.allocationPoints);
        console.log("status ", uint256(cashReserve.status));
    }

    function test_SonicRebalance() public {
        address[] memory strats = new address[](3);
        strats[2] = address(aaveStrategy);
        strats[1] = address(eulerStrategy1);
        strats[0] = address(eulerStrategy2);

        vm.prank(admin);

        uint256 gasBefore = gasleft();
        vault.rebalance(strats);
        uint256 gasAfter = gasleft();
        console.log("Gas used:", gasBefore - gasAfter);
    }
}
