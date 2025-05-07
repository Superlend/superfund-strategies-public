// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";
import {TestBase} from "./helpers/TestBase.sol";
import {IEulerEarnFactory} from "euler-earn/src/interface/IEulerEarnFactory.sol";
import {IEulerEarn} from "euler-earn/src/interface/IEulerEarn.sol";
import {IERC20Metadata} from "openzeppelin-contracts/contracts/interfaces/IERC20Metadata.sol";
import {IAccessControl} from "openzeppelin-contracts/contracts/access/IAccessControl.sol";
import {ConstantsLib} from "euler-earn/src/lib/ConstantsLib.sol";

contract EulerEarnVault is TestBase {
    uint256 chainId = chainIds.BASE;
    IEulerEarnFactory eEarnfactory;
    IERC20Metadata token;
    address tokenWhale;
    address userAddress1;
    address userAddress2;

    address aaveStrategy = 0x7aC16Ce4829833F069f345A00B1CFc5b27916530;
    address fluidStrategy = 0xf42f5795D9ac7e9D757dB633D693cD548Cfd9169;
    address morphoStrategy = 0xeE8F4eC5672F09119b96Ab6fB59C27E1b7e44b61;

    function setUp() public override {
        super.setUp();

        string memory forkUrl = rpcUrls[chainId];
        vm.createSelectFork(forkUrl);

        // define factory contract
        eEarnfactory = IEulerEarnFactory(eEarnFactoryContracts[chainId]);
        token = IERC20Metadata(usdc[chainId]);

        tokenWhale = usdcWhale[chainId];

        userAddress1 = vm.addr(0x123);
        userAddress2 = vm.addr(0x567);
    }

    function test_DeployEulerEarnVault() public {
        // console.log(
        //     "deployed euler earn vault address ",
        //     address(_deployVault())
        // );
        address account = userAddress1;
        address reward = userAddress2;
        uint256 claimable = 123456789;
        console.log("account ", account);
        console.log("reward ", reward);
        console.logBytes(abi.encode(account, reward, claimable));
        console.logBytes32(keccak256(abi.encode(account, reward, claimable)));
        console.logBytes(
            bytes.concat(keccak256(abi.encode(account, reward, claimable)))
        );
        // keccak256(bytes.concat(keccak256(abi.encode(account, reward, claimable))))
    }
}

//     function test_AddStrategy() public {
//         IEulerEarn vault = _deployVault();
//         _setupStrategies(vault);

//         address[] memory wQueue = vault.withdrawalQueue();
//         assert(wQueue.length == 3);

//         uint256 totalAllocationPts = vault.totalAllocationPoints();
//         assert(totalAllocationPts == 1000_000);
//     }

//     function test_Deposit() public {
//         IEulerEarn vault = _deployVault();
//         _setupStrategies(vault);

//         uint256 depositAmount = 1000 * (10 ** token.decimals());
//         _addLiquidity(vault, depositAmount);

//         uint256 deposited = vault.totalAssetsDeposited();
//         uint256 allocated = vault.totalAllocated();

//         assert(deposited == 3 * depositAmount);
//         assert(allocated == 0);
//     }

//     function test_Rebalance() public {
//         IEulerEarn vault = _deployVault();
//         _setupStrategies(vault);

//         uint256 depositAmount = 1000 * (10 ** token.decimals());
//         _addLiquidity(vault, depositAmount);
//         _rebalanceAll(vault);

//         uint256 totalAllocated = vault.totalAllocated();
//         IEulerEarn.Strategy memory cashReserve = vault.getStrategy(address(0));
//         IEulerEarn.Strategy memory aave = vault.getStrategy(aaveStrategy);
//         IEulerEarn.Strategy memory fluid = vault.getStrategy(fluidStrategy);
//         IEulerEarn.Strategy memory morpho = vault.getStrategy(morphoStrategy);

//         assert(totalAllocated == (3 * depositAmount * 99) / 100);
//         assert(cashReserve.allocated == 0);
//         assert(token.balanceOf(address(vault)) == 3 * depositAmount - totalAllocated);
//         assert(aave.allocated == (depositAmount * 99) / 100);
//         assert(fluid.allocated == (depositAmount * 99) / 100);
//         assert(morpho.allocated == (depositAmount * 99) / 100);
//     }

//     function test_Harvest() public {
//         IEulerEarn vault = _deployVault();
//         _setupStrategies(vault);

//         uint256 depositAmount = 1000 * (10 ** token.decimals());
//         _addLiquidity(vault, depositAmount);
//         _rebalanceAll(vault);

//         vm.warp(block.timestamp + 86400 * 365);
//         vault.harvest();
//         vm.warp(block.timestamp + 86400 * 2); // fast forwaring again for smearing period

//         assert(vault.totalAllocated() > 3 * depositAmount);
//         assert(vault.totalAssets() > 3 * depositAmount);
//     }

//     function test_UpdateAllocationPoints() public {
//         IEulerEarn vault = _deployVault();
//         _setupStrategies(vault);

//         uint256 depositAmount = 1000 * (10 ** token.decimals());
//         _addLiquidity(vault, depositAmount);
//         _rebalanceAll(vault);
//         vm.warp(block.timestamp + 86400 * 365);
//         vault.harvest();
//         vm.warp(block.timestamp + 86400 + 10);

//         _adjustAllocationPoints(vault);
//         _rebalanceAll(vault);

//         IEulerEarn.Strategy memory cashReserve = vault.getStrategy(address(0));
//         IEulerEarn.Strategy memory aave = vault.getStrategy(aaveStrategy);
//         IEulerEarn.Strategy memory fluid = vault.getStrategy(fluidStrategy);
//         IEulerEarn.Strategy memory morpho = vault.getStrategy(morphoStrategy);

//         assert(cashReserve.allocationPoints == 10_000);
//         assert(aave.allocationPoints == 190_000);
//         assert(fluid.allocationPoints == 400_000);
//         assert(morpho.allocationPoints == 400_000);
//     }

//     function test_Withdraw() public {
//         IEulerEarn vault = _deployVault();
//         _setupStrategies(vault);

//         uint256 depositAmount = 1000 * (10 ** token.decimals());
//         _addLiquidity(vault, depositAmount);
//         _rebalanceAll(vault);
//         vm.warp(block.timestamp + 86400 * 365);
//         vault.harvest();
//         vm.warp(block.timestamp + 86400 + 10);

//         uint256 initialBalance = token.balanceOf(tokenWhale);
//         uint256 withdrawAmount = 1 * (10 ** token.decimals());
//         uint256 initialCashReserve = token.balanceOf(address(vault));

//         IEulerEarn.Strategy memory aave = vault.getStrategy(aaveStrategy);
//         uint256 initialAaveAllocation = aave.allocated;
//         console.log("allocated to aave 1 : ", aave.allocated);

//         vm.prank(tokenWhale);
//         vault.withdraw(withdrawAmount, tokenWhale, tokenWhale);

//         uint256 finalCashReserve = token.balanceOf(address(vault));
//         uint256 finalBalance = token.balanceOf(tokenWhale);

//         assert(initialCashReserve - finalCashReserve == withdrawAmount);
//         assert(finalBalance - initialBalance == withdrawAmount);

//         initialBalance = finalBalance;
//         // try to withdraw from one of the strats
//         withdrawAmount = 100 * (10 ** token.decimals());
//         vm.prank(tokenWhale);
//         vault.withdraw(withdrawAmount, tokenWhale, tokenWhale);
//         finalBalance = token.balanceOf(tokenWhale);
//         finalCashReserve = token.balanceOf(address(vault));

//         assert(finalBalance - initialBalance == withdrawAmount);
//         assert(finalCashReserve == 0);

//         aave = vault.getStrategy(aaveStrategy);

//         console.log("allocated to aave 2 : ", aave.allocated);
//         assert(aave.allocated < initialAaveAllocation);

//         _rebalanceAll(vault);

//         aave = vault.getStrategy(aaveStrategy);
//         console.log("allocated to aave 3 : ", aave.allocated);
//         console.log("cash reserve finally after rebalance : ", token.balanceOf(address(vault)));
//     }

//     function test_RewardInterest() public {
//         IEulerEarn vault = _deployVault();
//         _setupStrategies(vault);

//         uint256 depositAmount = 1000 * (10 ** token.decimals());
//         _addLiquidity(vault, depositAmount);
//         _rebalanceAll(vault);
//         // vm.warp(block.timestamp + 86400 * 365);

//         // deposit some usdc in aave wrapper on behalf of our vault and call harvest
//         vm.prank(tokenWhale);
//         token.approve(aaveStrategy, type(uint256).max);

//         vm.prank(tokenWhale);
//         IEulerEarn(aaveStrategy).deposit(depositAmount, address(vault));

//         vault.harvest();

//         // read the total stuff
//         uint256 totalDeposited = vault.totalAssetsDeposited();
//         uint256 totalAllocated = vault.totalAllocated();
//         uint256 totalAssets = vault.totalAssets();
//         // vm.warp(block.timestamp + 86400);
//         uint256 interestAccrued = vault.interestAccrued();
//         IEulerEarn.Strategy memory aave = vault.getStrategy(aaveStrategy);
//         (,, uint168 intLeft) = vault.getEulerEarnSavingRate();
//         console.log("allocated to aave ", aave.allocated);
//         console.log("total deposits ", totalDeposited);
//         console.log("total allocated ", totalAllocated);
//         console.log("total assets  ", totalAssets);
//         console.log("interest accured  ", interestAccrued);
//         console.log("int left ", intLeft);
//     }

//     function _deployVault() internal returns (IEulerEarn) {
//         address asset = address(token);
//         string memory name = "Test USDC Vault";
//         string memory symbol = "TUV";
//         uint256 initialCashAllocationPoints = 10_000; // aiming 1m as total allocation points => 1% of total
//         uint24 smearingPeriod = 86400;

//         IEulerEarn eEarnVault =
//             IEulerEarn(eEarnfactory.deployEulerEarn(asset, name, symbol, initialCashAllocationPoints, smearingPeriod));

//         address userAddress = address(this);

//         // grant admin roles to deployer
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.GUARDIAN_ADMIN, userAddress);
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.STRATEGY_OPERATOR_ADMIN, userAddress);
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.EULER_EARN_MANAGER_ADMIN, userAddress);
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.WITHDRAWAL_QUEUE_MANAGER_ADMIN, userAddress);
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.REBALANCER_ADMIN, userAddress);

//         // grant roles to deployer
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.GUARDIAN, userAddress);
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.STRATEGY_OPERATOR, userAddress);
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.EULER_EARN_MANAGER, userAddress);
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.WITHDRAWAL_QUEUE_MANAGER, userAddress);
//         IAccessControl(address(eEarnVault)).grantRole(ConstantsLib.REBALANCER, userAddress);

//         return eEarnVault;
//     }

//     function _setupStrategies(IEulerEarn vault) internal {
//         uint256 eachAllocationPts = 990_000 / 3;

//         vault.addStrategy(aaveStrategy, eachAllocationPts);
//         vault.addStrategy(fluidStrategy, eachAllocationPts);
//         vault.addStrategy(morphoStrategy, eachAllocationPts);
//     }

//     function _addLiquidity(IEulerEarn vault, uint256 depositAmount) internal {
//         vm.startPrank(tokenWhale);
//         token.approve(address(vault), type(uint256).max);

//         vault.deposit(depositAmount, tokenWhale);
//         vault.deposit(depositAmount, userAddress1);
//         vault.deposit(depositAmount, userAddress2);

//         vm.stopPrank();
//     }

//     function _rebalanceAll(IEulerEarn vault) internal {
//         address[] memory strategies = new address[](3);
//         strategies[0] = fluidStrategy;
//         strategies[1] = aaveStrategy;
//         strategies[2] = morphoStrategy;

//         vault.rebalance(strategies);
//     }

//     function _adjustAllocationPoints(IEulerEarn vault) internal {
//         // 1% cash reserve => 10_000
//         // 19% in aave => 190_000
//         // 40% in morpho => 400_000
//         // 40% in fluid => 400_000

//         vault.adjustAllocationPoints(aaveStrategy, 190_000);
//         vault.adjustAllocationPoints(fluidStrategy, 400_000);
//         vault.adjustAllocationPoints(morphoStrategy, 400_000);
//     }
// }

// 0x
// 000000000000000000000000476c88ed464efd251a8b18eb84785f7c46807873
// 000000000000000000000000d590c4417a93569e48677dbd5aca2cf7ff73909c
// 00000000000000000000000000000000000000000000000000000000075bcd15

// 0x
// 000000000000000000000000476c88ed464efd251a8b18eb84785f7c46807873
// 000000000000000000000000d590c4417a93569e48677dbd5aca2cf7ff73909c
// 00000000000000000000000000000000000000000000000000000000075bcd15
