// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Vm} from "forge-std/Test.sol";
import {TestBase} from "../helpers/TestBase.sol";
import {SuperlendSiloV2Strategy} from "../../src/silo/SiloV2Strategy.sol";
import {SuperlendSiloV2StrategyV2} from "../../src/mock/SiloV2StrategyV2.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/interfaces/IERC20Metadata.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract SiloV2Test is TestBase {
    uint256 chainId = chainIds.SONIC;
    SuperlendSiloV2Strategy silo;
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
        address siloStrategyImplementation = address(
            new SuperlendSiloV2Strategy()
        );

        vm.recordLogs();
        // deploy proxy
        silo = SuperlendSiloV2Strategy(
            address(
                new TransparentUpgradeableProxy(
                    siloStrategyImplementation,
                    address(this),
                    ""
                )
            )
        );

        Vm.Log[] memory logs = vm.getRecordedLogs();
        uint256 logsLength = logs.length;
        for (uint i = 0; i < logsLength; i++) {
            if (logs[i].emitter == address(silo) && logs[i].data.length > 0) {
                (, address newAdmin) = abi.decode(
                    logs[i].data,
                    (address, address)
                );
                proxyAdmin = newAdmin;
            }
        }

        // initalize
        silo.initialize(
            "SuperlendSiloV2 Usdc",
            "slSilo USDC",
            usdc[chainId],
            siloVault[chainId]
        );

        tokenWhale = usdcWhale[chainId];
        token = IERC20Metadata(usdc[chainId]);
    }

    // Deposit flow

    function test_depositSiloSingleUser() public {
        _setup();

        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(silo), depositAmount);
        silo.deposit(depositAmount, tokenWhale);
        vm.stopPrank();

        console.log("Initial state ---------------", block.timestamp);
        console.log("total assets ", silo.totalAssets());
        console.log("balance of whale ", silo.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", silo.maxWithdraw(tokenWhale));

        vm.warp(block.timestamp + 86400 * 365);
        console.log("Final state ----------------", block.timestamp);
        console.log("total assets ", silo.totalAssets());
        console.log("balance of whale ", silo.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", silo.maxWithdraw(tokenWhale));
    }

    function test_depositSiloMultipleUsers() public {
        _setup();
        address userAddress1 = vm.addr(0x123);
        address userAddress2 = vm.addr(0x345);

        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(silo), depositAmount);
        silo.deposit(depositAmount, tokenWhale);
        console.log("Initial state ---------------", block.timestamp);
        console.log("Total assets ", silo.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", silo.balanceOf(tokenWhale));
        console.log("User1 ", silo.balanceOf(userAddress1));
        console.log("User2 ", silo.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", silo.maxWithdraw(tokenWhale));
        console.log("User1 ", silo.maxWithdraw(userAddress1));
        console.log("User2 ", silo.maxWithdraw(userAddress2));

        vm.warp(block.timestamp + 86400 * 365);
        token.approve(address(silo), 3 * depositAmount);
        silo.deposit(depositAmount, userAddress1);
        silo.deposit(2 * depositAmount, userAddress2);

        console.log("Intermediate state ---------------", block.timestamp);
        console.log("Total assets ", silo.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", silo.balanceOf(tokenWhale));
        console.log("User1 ", silo.balanceOf(userAddress1));
        console.log("User2 ", silo.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", silo.maxWithdraw(tokenWhale));
        console.log("User1 ", silo.maxWithdraw(userAddress1));
        console.log("User2 ", silo.maxWithdraw(userAddress2));
        vm.stopPrank();

        vm.warp(block.timestamp + 86400 * 365);

        console.log("Final state ---------------", block.timestamp);
        console.log("Total assets ", silo.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", silo.balanceOf(tokenWhale));
        console.log("User1 ", silo.balanceOf(userAddress1));
        console.log("User2 ", silo.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", silo.maxWithdraw(tokenWhale));
        console.log("User1 ", silo.maxWithdraw(userAddress1));
        console.log("User2 ", silo.maxWithdraw(userAddress2));
    }

    function test_depositSiloFail() public {
        _setup();

        uint256 depositAmount = silo.maxDeposit(tokenWhale) + 100;
        vm.startPrank(tokenWhale);
        token.approve(address(silo), depositAmount);
        vm.expectRevert(bytes("ERC4626: deposit more than max"));
        silo.deposit(depositAmount, tokenWhale);

        vm.expectRevert(bytes("ERC4626: zero deposit"));
        silo.deposit(0, tokenWhale);

        vm.stopPrank();
    }

    function test_mintSiloSingleUser() public {
        _setup();
        uint256 mintAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(silo), mintAmount * 100);
        silo.mint(mintAmount, tokenWhale);
        vm.stopPrank();

        console.log("Initial state ---------------", block.timestamp);
        console.log("total assets ", silo.totalAssets());
        console.log("balance of whale ", silo.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", silo.maxWithdraw(tokenWhale));

        vm.warp(block.timestamp + 86400 * 365);
        console.log("Final state ----------------", block.timestamp);
        console.log("total assets ", silo.totalAssets());
        console.log("balance of whale ", silo.balanceOf(tokenWhale));
        console.log("max withdraw for whale ", silo.maxWithdraw(tokenWhale));
    }

    function test_mintSiloMultipleUsers() public {
        _setup();
        address userAddress1 = vm.addr(0x123);
        address userAddress2 = vm.addr(0x345);

        uint256 mintAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(silo), mintAmount * 100);
        silo.mint(mintAmount, tokenWhale);
        console.log("Initial state ---------------", block.timestamp);
        console.log("Total assets ", silo.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", silo.balanceOf(tokenWhale));
        console.log("User1 ", silo.balanceOf(userAddress1));
        console.log("User2 ", silo.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", silo.maxWithdraw(tokenWhale));
        console.log("User1 ", silo.maxWithdraw(userAddress1));
        console.log("User2 ", silo.maxWithdraw(userAddress2));

        vm.warp(block.timestamp + 86400 * 365);
        silo.mint(mintAmount, userAddress1);
        silo.mint(2 * mintAmount, userAddress2);

        console.log("Intermediate state ---------------", block.timestamp);
        console.log("Total assets ", silo.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", silo.balanceOf(tokenWhale));
        console.log("User1 ", silo.balanceOf(userAddress1));
        console.log("User2 ", silo.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", silo.maxWithdraw(tokenWhale));
        console.log("User1 ", silo.maxWithdraw(userAddress1));
        console.log("User2 ", silo.maxWithdraw(userAddress2));
        vm.stopPrank();

        vm.warp(block.timestamp + 86400 * 365);

        console.log("Final state ---------------", block.timestamp);
        console.log("Total assets ", silo.totalAssets());
        console.log("Balances: ");
        console.log("Whale ", silo.balanceOf(tokenWhale));
        console.log("User1 ", silo.balanceOf(userAddress1));
        console.log("User2 ", silo.balanceOf(userAddress2));
        console.log("Withdraw: ");
        console.log("Whale ", silo.maxWithdraw(tokenWhale));
        console.log("User1 ", silo.maxWithdraw(userAddress1));
        console.log("User2 ", silo.maxWithdraw(userAddress2));
    }

    function test_mintSiloFail() public {
        _setup();
        uint256 mintAmount = silo.maxMint(tokenWhale) + 100;
        vm.startPrank(tokenWhale);
        token.approve(address(silo), mintAmount);
        vm.expectRevert(bytes("ERC4626: mint more than max"));
        silo.mint(mintAmount, tokenWhale);

        vm.expectRevert(bytes("ERC4626: zero mint"));
        silo.mint(0, tokenWhale);

        vm.stopPrank();
    }

    function test_siloWithdraw() public {
        _setup();
        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(silo), depositAmount);
        silo.deposit(depositAmount, tokenWhale);

        vm.warp(block.timestamp + 365 * 86400);

        vm.expectRevert(bytes("ERC4626: zero withdraw"));
        silo.withdraw(0, tokenWhale, tokenWhale);

        uint256 maxWithdraw = silo.maxWithdraw(tokenWhale) + 100;
        vm.expectRevert(bytes("ERC4626: withdraw more than max"));
        silo.withdraw(maxWithdraw, tokenWhale, tokenWhale);

        uint256 withdrawAmt = 20 * (10 ** token.decimals());
        uint256 currentTokenBalance = token.balanceOf(tokenWhale);
        uint256 currentShareBalance = silo.balanceOf(tokenWhale);

        silo.withdraw(withdrawAmt, tokenWhale, tokenWhale);

        uint256 fnlTokenBalance = token.balanceOf(tokenWhale);
        uint256 fnlShareBalance = silo.balanceOf(tokenWhale);

        assert(fnlTokenBalance - currentTokenBalance == withdrawAmt);

        console.log("current share balance", currentShareBalance);
        console.log("fnl share balance", fnlShareBalance);
        console.log("withdraw amt ", silo.maxWithdraw(tokenWhale));

        vm.stopPrank();
    }

    function test_redeemSilo() public {
        _setup();
        uint256 depositAmount = 100 * (10 ** token.decimals());
        vm.startPrank(tokenWhale);
        token.approve(address(silo), depositAmount);
        silo.deposit(depositAmount, tokenWhale);

        vm.warp(block.timestamp + 365 * 86400);

        vm.expectRevert(bytes("ERC4626: zero redeem"));
        silo.redeem(0, tokenWhale, tokenWhale);

        uint256 maxRedeem = silo.maxRedeem(tokenWhale) + 100;
        vm.expectRevert(bytes("ERC4626: redeem more than max"));
        silo.redeem(maxRedeem, tokenWhale, tokenWhale);

        //
        uint256 redeemAmt = 20 * (10 ** token.decimals());
        uint256 currentTokenBalance = token.balanceOf(tokenWhale);
        uint256 currentShareBalance = silo.balanceOf(tokenWhale);

        silo.redeem(redeemAmt, tokenWhale, tokenWhale);

        uint256 fnlTokenBalance = token.balanceOf(tokenWhale);
        uint256 fnlShareBalance = silo.balanceOf(tokenWhale);

        assert(currentShareBalance - fnlShareBalance == redeemAmt);

        console.log("current token balance", currentTokenBalance);
        console.log("fnl token balance", fnlTokenBalance);
        console.log("withdraw amt ", silo.maxWithdraw(tokenWhale));

        vm.stopPrank();
    }

    function test_SiloUpgrade() public {
        test_depositSiloSingleUser();
        uint256 oldTotalAssets = silo.totalAssets();
        uint256 oldBalance = silo.balanceOf(tokenWhale);

        // should revert
        vm.expectRevert();
        SuperlendSiloV2StrategyV2(address(silo)).newMockFunction();

        // deploy the v2
        SuperlendSiloV2StrategyV2 siloV2 = new SuperlendSiloV2StrategyV2();
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(silo)),
            address(siloV2),
            ""
        );
        uint mockFunctionValue = SuperlendSiloV2StrategyV2(address(silo))
            .newMockFunction();

        console.log("mock funciton value ", mockFunctionValue);
        uint256 newTotalAssets = silo.totalAssets();
        uint256 newBalance = silo.balanceOf(tokenWhale);

        assert(oldTotalAssets == newTotalAssets);
        assert(oldBalance == newBalance);

        // try to withdraw for this user
        vm.warp(block.timestamp + 365 * 86400);

        uint256 withdrawAmt = 20 * (10 ** token.decimals());
        uint256 currentTokenBalance = token.balanceOf(tokenWhale);

        vm.prank(tokenWhale);
        silo.withdraw(withdrawAmt, tokenWhale, tokenWhale);

        uint256 fnlTokenBalance = token.balanceOf(tokenWhale);

        assert(fnlTokenBalance - currentTokenBalance == withdrawAmt);
    }
}
