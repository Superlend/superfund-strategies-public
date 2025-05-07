// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SuperlendEulerV2Strategy} from "../euler/EulerV2Strategy.sol";

contract SuperlendEulerV2StrategyV2 is SuperlendEulerV2Strategy {
    function newMockFunction() public pure returns (uint256) {
        return 100_000_000;
    }
}
