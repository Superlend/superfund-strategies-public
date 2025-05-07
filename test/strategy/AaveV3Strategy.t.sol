// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Vm} from "forge-std/Test.sol";
import {TestBase} from "../helpers/TestBase.sol";
import {SuperlendAaveV3Strategy} from "../../src/aave/AaveV3Strategy.sol";
import {SuperlendAaveV3StrategyV2} from "../../src/mock/AaveV3StrategyV2.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/interfaces/IERC20Metadata.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract AaveV3Test is TestBase {
    uint256 chainId = chainIds.BASE;
    SuperlendAaveV3Strategy aave;
    IERC20Metadata token;
    address tokenWhale;
    address proxyAdmin;

    function setUp() public override {
        super.setUp();

        string memory forkUrl = rpcUrls[chainId];
        vm.createSelectFork(forkUrl);
    }

    function _setup() internal {
        // deploy implementation
        address aaveStrategyImplementation = address(
            new SuperlendAaveV3Strategy()
        );

        vm.recordLogs();
        // deploy proxy
        aave = SuperlendAaveV3Strategy(
            address(
                new TransparentUpgradeableProxy(
                    aaveStrategyImplementation,
                    address(this),
                    ""
                )
            )
        );

        Vm.Log[] memory logs = vm.getRecordedLogs();
        uint256 logsLength = logs.length;
        for (uint i = 0; i < logsLength; i++) {
            if (logs[i].emitter == address(aave) && logs[i].data.length > 0) {
                (, address newAdmin) = abi.decode(
                    logs[i].data,
                    (address, address)
                );
                proxyAdmin = newAdmin;
            }
        }

        // initalize
        aave.initialize(
            "SuperlendAaveV3",
            "slAave",
            usdc[chainId],
            pool[chainId]
        );

        tokenWhale = usdcWhale[chainId];
        token = IERC20Metadata(usdc[chainId]);
    }

    /// Deposit flow

    function test_depositSingleUser() public {
        _setup();

        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(aave), depositAmount);
        aave.deposit(depositAmount, tokenWhale);
        vm.stopPrank();

        console.log("Initial state ---------------", block.timestamp);
        console.log("total assets ", aave.totalAssets());
        console.log("balance of whale ", aave.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", aave.maxWithdraw(tokenWhale));

        vm.warp(block.timestamp + 86400 * 365);
        console.log("Final state ----------------", block.timestamp);
        console.log("total assets ", aave.totalAssets());
        console.log("balance of whale ", aave.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", aave.maxWithdraw(tokenWhale));
    }

    function test_upgrade() public {
        test_depositSingleUser();
        uint256 oldTotalAssets = aave.totalAssets();
        uint256 oldBalance = aave.balanceOf(tokenWhale);

        // should revert
        vm.expectRevert();
        SuperlendAaveV3StrategyV2(address(aave)).newMockFunction();

        // deploy the v2
        SuperlendAaveV3StrategyV2 aaveV2 = new SuperlendAaveV3StrategyV2();
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(aave)),
            address(aaveV2),
            ""
        );
        uint mockFunctionValue = SuperlendAaveV3StrategyV2(address(aave))
            .newMockFunction();

        console.log("mock funciton value ", mockFunctionValue);
        uint256 newTotalAssets = aave.totalAssets();
        uint256 newBalance = aave.balanceOf(tokenWhale);

        assert(oldTotalAssets == newTotalAssets);
        assert(oldBalance == newBalance);

        // try to withdraw for this user
        vm.warp(block.timestamp + 365 * 86400);

        uint256 withdrawAmt = 20 * (10 ** token.decimals());
        uint256 currentTokenBalance = token.balanceOf(tokenWhale);

        vm.prank(tokenWhale);
        aave.withdraw(withdrawAmt, tokenWhale, tokenWhale);

        uint256 fnlTokenBalance = token.balanceOf(tokenWhale);

        assert(fnlTokenBalance - currentTokenBalance == withdrawAmt);
    }
}
