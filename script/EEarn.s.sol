// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";

import {IEulerEarnFactory} from "euler-earn/src/interface/IEulerEarnFactory.sol";
import {IEulerEarn} from "euler-earn/src/interface/IEulerEarn.sol";
import {ScriptBase} from "./ScriptBase.sol";
import {ConstantsLib} from "euler-earn/src/lib/ConstantsLib.sol";
import {IAccessControl} from "openzeppelin-contracts/contracts/access/IAccessControl.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
// import {MockAaveAdapter} from "../src/mock/MockAaveV3.sol";
// import {MockFluidAdapter} from "../src/mock/MockFluid.sol";

contract EEarnScript is ScriptBase {
    uint256 chainId = chainIds.SONIC;
    IEulerEarnFactory eEarnfactory;
    IEulerEarn public eEarnVault;
    IERC20 token;
    uint256 deployerPvtKey;
    address deployerAddress;

    function setUp() public override {
        super.setUp();
        vm.createSelectFork("sonic");

        deployerPvtKey = vm.envUint("PRIVATE_KEY");
        deployerAddress = vm.addr(deployerPvtKey);

        eEarnfactory = IEulerEarnFactory(eEarnFactoryContracts[chainId]);
        token = IERC20(usdc[chainId]);
    }

    function run() public {
        vm.startBroadcast(deployerPvtKey);

        address eEarnVaultAddress = _deploy();
        eEarnVault = IEulerEarn(eEarnVaultAddress);
        _setRoles(deployerAddress);
        _setStrategies();

        vm.stopBroadcast();
    }

    function _deploy() internal returns (address) {
        address asset = address(token);
        string memory name = "Superlend USD";
        string memory symbol = "slUSD";
        // aiming the total allocation point to be 1_000_000
        uint256 initialCashAllocationPoints = 10_000; // 1% of 1M
        uint24 smearingPeriod = 86400; // 1 day in seconds

        address eEarnVaultAddress = eEarnfactory.deployEulerEarn(
            asset,
            name,
            symbol,
            initialCashAllocationPoints,
            smearingPeriod
        );
        console.log("earn vault address", eEarnVaultAddress);
        return eEarnVaultAddress;
    }

    function _setRoles(address userAddress) internal {
        // grant admin roles to deployer
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.GUARDIAN_ADMIN,
            userAddress
        );
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.STRATEGY_OPERATOR_ADMIN,
            userAddress
        );
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.EULER_EARN_MANAGER_ADMIN,
            userAddress
        );
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.WITHDRAWAL_QUEUE_MANAGER_ADMIN,
            userAddress
        );
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.REBALANCER_ADMIN,
            userAddress
        );

        // grant roles to deployer
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.GUARDIAN,
            userAddress
        );
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.STRATEGY_OPERATOR,
            userAddress
        );
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.EULER_EARN_MANAGER,
            userAddress
        );
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.WITHDRAWAL_QUEUE_MANAGER,
            userAddress
        );
        IAccessControl(address(eEarnVault)).grantRole(
            ConstantsLib.REBALANCER,
            userAddress
        );
    }

    function _deployDummyStrats() internal returns (address[2] memory) {
        address asset = address(token);

        address mockAave = address(0);
        //  address(
        //     new MockAaveAdapter(
        //         "supervault_test_usdc_aavev3",
        //         "svtUSDCaave",
        //         asset
        //     )
        // );
        address mockFluid = address(0);
        // address(
        //     new MockFluidAdapter(
        //         "supervault_test_usdc_fluid",
        //         "svtUSDCfluid",
        //         asset
        //     )
        // );

        console.log("aave adapter", mockAave);
        console.log("aave fluid", mockFluid);

        address[2] memory stratArray = [mockAave, mockFluid];
        return stratArray;
    }

    function _setStrategies() internal {
        address[1] memory strats = [0x7342c3387EfBbcc9fa505027bd1fDB0093e6E8bA];

        uint256[1] memory allocationPoints = [uint256(100)];
        for (uint256 i; i < strats.length; i++) {
            eEarnVault.addStrategy(strats[i], allocationPoints[i]);
        }
    }
}
