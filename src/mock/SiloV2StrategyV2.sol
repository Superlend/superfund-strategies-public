// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SuperlendSiloV2Strategy} from "../silo/SiloV2Strategy.sol";

contract SuperlendSiloV2StrategyV2 is SuperlendSiloV2Strategy {
    function newMockFunction() public pure returns (uint256) {
        return 100_000_000;
    }
}
