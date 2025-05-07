// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Vm} from "forge-std/Test.sol";
import {TestBase} from "../helpers/TestBase.sol";
import {SuperlendEulerV2Strategy} from "../../src/euler/EulerV2Strategy.sol";
import {SuperlendEulerV2StrategyV2} from "../../src/mock/EulerV2StrategyV2.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/interfaces/IERC20Metadata.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract EulerV2Test is TestBase {
    uint256 chainId = chainIds.BASE;
    SuperlendEulerV2Strategy euler;
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
        address eulerStrategyImplementation = address(
            new SuperlendEulerV2Strategy()
        );

        vm.recordLogs();
        // deploy proxy
        euler = SuperlendEulerV2Strategy(
            address(
                new TransparentUpgradeableProxy(
                    eulerStrategyImplementation,
                    address(this),
                    ""
                )
            )
        );

        Vm.Log[] memory logs = vm.getRecordedLogs();
        uint256 logsLength = logs.length;
        for (uint i = 0; i < logsLength; i++) {
            if (logs[i].emitter == address(euler) && logs[i].data.length > 0) {
                (, address newAdmin) = abi.decode(
                    logs[i].data,
                    (address, address)
                );
                proxyAdmin = newAdmin;
            }
        }

        // initalize
        euler.initialize(
            "SuperlendEulerV2 Usdc",
            "slEul USDC",
            usdc[chainId],
            eulerVault[chainId]
        );

        tokenWhale = usdcWhale[chainId];
        token = IERC20Metadata(usdc[chainId]);
    }

    // Deposit flow

    function test_depositEulerSingleUser() public {
        _setup();

        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(euler), depositAmount);
        euler.deposit(depositAmount, tokenWhale);
        vm.stopPrank();

        console.log("Initial state ---------------", block.timestamp);
        console.log("total assets ", euler.totalAssets());
        console.log("balance of whale ", euler.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", euler.maxWithdraw(tokenWhale));

        vm.warp(block.timestamp + 86400 * 365);
        console.log("Final state ----------------", block.timestamp);
        console.log("total assets ", euler.totalAssets());
        console.log("balance of whale ", euler.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", euler.maxWithdraw(tokenWhale));
    }

    function test_depositEulerMultipleUsers() public {
        _setup();
        address userAddress1 = vm.addr(0x123);
        address userAddress2 = vm.addr(0x345);

        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(euler), depositAmount);
        euler.deposit(depositAmount, tokenWhale);
        console.log("Initial state ---------------", block.timestamp);
        console.log("Total assets ", euler.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", euler.balanceOf(tokenWhale));
        console.log("User1 ", euler.balanceOf(userAddress1));
        console.log("User2 ", euler.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", euler.maxWithdraw(tokenWhale));
        console.log("User1 ", euler.maxWithdraw(userAddress1));
        console.log("User2 ", euler.maxWithdraw(userAddress2));

        vm.warp(block.timestamp + 86400 * 365);
        token.approve(address(euler), 3 * depositAmount);
        euler.deposit(depositAmount, userAddress1);
        euler.deposit(2 * depositAmount, userAddress2);

        console.log("Intermediate state ---------------", block.timestamp);
        console.log("Total assets ", euler.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", euler.balanceOf(tokenWhale));
        console.log("User1 ", euler.balanceOf(userAddress1));
        console.log("User2 ", euler.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", euler.maxWithdraw(tokenWhale));
        console.log("User1 ", euler.maxWithdraw(userAddress1));
        console.log("User2 ", euler.maxWithdraw(userAddress2));
        vm.stopPrank();

        vm.warp(block.timestamp + 86400 * 365);

        console.log("Final state ---------------", block.timestamp);
        console.log("Total assets ", euler.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", euler.balanceOf(tokenWhale));
        console.log("User1 ", euler.balanceOf(userAddress1));
        console.log("User2 ", euler.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", euler.maxWithdraw(tokenWhale));
        console.log("User1 ", euler.maxWithdraw(userAddress1));
        console.log("User2 ", euler.maxWithdraw(userAddress2));
    }

    function test_depositEulerFail() public {
        _setup();

        uint256 depositAmount = euler.maxDeposit(tokenWhale) + 100;
        vm.startPrank(tokenWhale);
        token.approve(address(euler), depositAmount);
        vm.expectRevert(bytes("ERC4626: deposit more than max"));
        euler.deposit(depositAmount, tokenWhale);

        vm.expectRevert(bytes("ERC4626: zero deposit"));
        euler.deposit(0, tokenWhale);

        vm.stopPrank();
    }

    function test_mintEulerSingleUser() public {
        _setup();
        uint256 mintAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(euler), mintAmount * 100);
        euler.mint(mintAmount, tokenWhale);
        vm.stopPrank();

        console.log("Initial state ---------------", block.timestamp);
        console.log("total assets ", euler.totalAssets());
        console.log("balance of whale ", euler.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", euler.maxWithdraw(tokenWhale));

        vm.warp(block.timestamp + 86400 * 365);
        console.log("Final state ----------------", block.timestamp);
        console.log("total assets ", euler.totalAssets());
        console.log("balance of whale ", euler.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", euler.maxWithdraw(tokenWhale));
    }

    function test_mintEulerMultipleUsers() public {
        _setup();
        address userAddress1 = vm.addr(0x123);
        address userAddress2 = vm.addr(0x345);

        uint256 mintAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(euler), mintAmount * 100);
        euler.mint(mintAmount, tokenWhale);
        console.log("Initial state ---------------", block.timestamp);
        console.log("Total assets ", euler.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", euler.balanceOf(tokenWhale));
        console.log("User1 ", euler.balanceOf(userAddress1));
        console.log("User2 ", euler.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", euler.maxWithdraw(tokenWhale));
        console.log("User1 ", euler.maxWithdraw(userAddress1));
        console.log("User2 ", euler.maxWithdraw(userAddress2));

        vm.warp(block.timestamp + 86400 * 365);
        euler.mint(mintAmount, userAddress1);
        euler.mint(2 * mintAmount, userAddress2);

        console.log("Intermediate state ---------------", block.timestamp);
        console.log("Total assets ", euler.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", euler.balanceOf(tokenWhale));
        console.log("User1 ", euler.balanceOf(userAddress1));
        console.log("User2 ", euler.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", euler.maxWithdraw(tokenWhale));
        console.log("User1 ", euler.maxWithdraw(userAddress1));
        console.log("User2 ", euler.maxWithdraw(userAddress2));
        vm.stopPrank();

        vm.warp(block.timestamp + 86400 * 365);

        console.log("Final state ---------------", block.timestamp);
        console.log("Total assets ", euler.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", euler.balanceOf(tokenWhale));
        console.log("User1 ", euler.balanceOf(userAddress1));
        console.log("User2 ", euler.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", euler.maxWithdraw(tokenWhale));
        console.log("User1 ", euler.maxWithdraw(userAddress1));
        console.log("User2 ", euler.maxWithdraw(userAddress2));
    }

    function test_mintEulerFail() public {
        _setup();
        uint256 mintAmount = euler.maxMint(tokenWhale) + 100;
        vm.startPrank(tokenWhale);
        token.approve(address(euler), mintAmount);
        vm.expectRevert(bytes("ERC4626: mint more than max"));
        euler.mint(mintAmount, tokenWhale);

        vm.expectRevert(bytes("ERC4626: zero mint"));
        euler.mint(0, tokenWhale);

        vm.stopPrank();
    }

    function test_eulerWithdraw() public {
        _setup();
        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(euler), depositAmount);
        euler.deposit(depositAmount, tokenWhale);

        vm.warp(block.timestamp + 365 * 86400);

        vm.expectRevert(bytes("ERC4626: zero withdraw"));
        euler.withdraw(0, tokenWhale, tokenWhale);

        uint256 maxWithdraw = euler.maxWithdraw(tokenWhale) + 100;
        vm.expectRevert(bytes("ERC4626: withdraw more than max"));
        euler.withdraw(maxWithdraw, tokenWhale, tokenWhale);

        uint256 withdrawAmt = 20 * (10 ** token.decimals());
        uint256 currentTokenBalance = token.balanceOf(tokenWhale);
        uint256 currentShareBalance = euler.balanceOf(tokenWhale);

        euler.withdraw(withdrawAmt, tokenWhale, tokenWhale);

        uint256 fnlTokenBalance = token.balanceOf(tokenWhale);
        uint256 fnlShareBalance = euler.balanceOf(tokenWhale);

        assert(fnlTokenBalance - currentTokenBalance == withdrawAmt);

        console.log("current share balance", currentShareBalance);
        console.log("fnl share balance", fnlShareBalance);
        console.log("withdraw amt ", euler.maxWithdraw(tokenWhale));

        vm.stopPrank();
    }

    function test_eulerRedeem() public {
        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(euler), depositAmount);
        euler.deposit(depositAmount, tokenWhale);

        vm.warp(block.timestamp + 365 * 86400);

        vm.expectRevert(bytes("ERC4626: zero redeem"));
        euler.redeem(0, tokenWhale, tokenWhale);

        uint256 maxRedeem = euler.maxRedeem(tokenWhale) + 100;
        vm.expectRevert(bytes("ERC4626: redeem more than max"));
        euler.redeem(maxRedeem, tokenWhale, tokenWhale);

        //
        uint256 redeemAmt = 20 * (10 ** token.decimals());
        uint256 currentTokenBalance = token.balanceOf(tokenWhale);
        uint256 currentShareBalance = euler.balanceOf(tokenWhale);

        euler.redeem(redeemAmt, tokenWhale, tokenWhale);

        uint256 fnlTokenBalance = token.balanceOf(tokenWhale);
        uint256 fnlShareBalance = euler.balanceOf(tokenWhale);

        assert(currentShareBalance - fnlShareBalance == redeemAmt);

        console.log("current token balance", currentTokenBalance);
        console.log("fnl token balance", fnlTokenBalance);
        console.log("withdraw amt ", euler.maxWithdraw(tokenWhale));

        vm.stopPrank();
    }

    function test_EulerUpgrade() public {
        test_depositEulerSingleUser();
        uint256 oldTotalAssets = euler.totalAssets();
        uint256 oldBalance = euler.balanceOf(tokenWhale);

        // should revert
        vm.expectRevert();
        SuperlendEulerV2StrategyV2(address(euler)).newMockFunction();

        // deploy the v2
        SuperlendEulerV2StrategyV2 eulerV2 = new SuperlendEulerV2StrategyV2();
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(euler)),
            address(eulerV2),
            ""
        );
        uint mockFunctionValue = SuperlendEulerV2StrategyV2(address(euler))
            .newMockFunction();

        console.log("mock funciton value ", mockFunctionValue);
        uint256 newTotalAssets = euler.totalAssets();
        uint256 newBalance = euler.balanceOf(tokenWhale);

        assert(oldTotalAssets == newTotalAssets);
        assert(oldBalance == newBalance);

        // try to withdraw for this user
        vm.warp(block.timestamp + 365 * 86400);

        uint256 withdrawAmt = 20 * (10 ** token.decimals());
        uint256 currentTokenBalance = token.balanceOf(tokenWhale);

        vm.prank(tokenWhale);
        euler.withdraw(withdrawAmt, tokenWhale, tokenWhale);

        uint256 fnlTokenBalance = token.balanceOf(tokenWhale);

        assert(fnlTokenBalance - currentTokenBalance == withdrawAmt);
    }
}
