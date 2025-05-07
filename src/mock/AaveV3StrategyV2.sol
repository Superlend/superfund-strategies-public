// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SuperlendAaveV3Strategy} from "../aave/AaveV3Strategy.sol";

contract SuperlendAaveV3StrategyV2 is SuperlendAaveV3Strategy {
    function newMockFunction() public pure returns (uint256) {
        return 100_000_000;
    }
}
