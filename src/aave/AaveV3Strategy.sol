// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC4626Upgradeable, Math} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {ReentrancyGuardUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import {Initializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";
import {DataTypes} from "aave-v3-core/contracts/protocol/libraries/types/DataTypes.sol";
import {ReserveConfiguration} from "aave-v3-core/contracts/protocol/libraries/configuration/ReserveConfiguration.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IAToken} from "aave-v3-core/contracts/interfaces/IAToken.sol";
import {WadRayMath} from "aave-v3-core/contracts/protocol/libraries/math/WadRayMath.sol";
import {SuperlendAaveV3StrategyBase} from "./AaveV3StrategyBase.sol";
/**
 * @title SuperlendAaveV3Strategy
 * @author Superlend
 * @notice An ERC4626-compliant vault that interfaces with Aave V3 reserves.
 *         This contract serves as an adapter between the Aave V3 protocol and
 *         the Superlend curated vault on the Euler Earn interface.
 * @dev Implements the ERC4626 standard.
 */
contract SuperlendAaveV3Strategy is
    SuperlendAaveV3StrategyBase,
    Initializable,
    ReentrancyGuardUpgradeable,
    ERC4626Upgradeable
{
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializes the vault with necessary parameters.
     * @param name_ Name of the ERC-20 token.
     * @param symbol_ Symbol of the ERC-20 token.
     * @param asset_ Address of the underlying asset.
     * @param pool_ Address of the Aave pool.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address asset_,
        address pool_
    ) public initializer {
        __ERC4626_init_unchained(IERC20(asset_));
        __ERC20_init_unchained(name_, symbol_);
        __ReentrancyGuard_init_unchained();
        __SuperlendAaveV3Strategy_init(pool_, asset_);
    }

    /**
     * @dev Internal initialization function.
     */
    function __SuperlendAaveV3Strategy_init(
        address pool_,
        address asset_
    ) internal onlyInitializing {
        SuperlendAaveV3StrategyStorage
            storage $ = _getSuperlendAaveV3StrategyStorage();
        $.pool = IPool(pool_);
        DataTypes.ReserveData memory reserveData = $.pool.getReserveData(
            asset_
        );
        $.aToken = IERC20(reserveData.aTokenAddress);
    }

    /**
     * @notice Returns the total assets managed by the vault.
     */
    function totalAssets() public view override returns (uint256) {
        SuperlendAaveV3StrategyStorage
            storage $ = _getSuperlendAaveV3StrategyStorage();
        return $.aToken.balanceOf(address(this));
    }

    function maxDeposit(address) public view override returns (uint256) {
        return _maxDeposit();
    }

    function maxMint(address) public view override returns (uint256) {
        return _convertToShares(_maxDeposit(), Math.Rounding.Floor);
    }

    /**
     * @dev Handles deposits and mints corresponding shares.
     */
    function deposit(
        uint256 assets,
        address receiver
    ) public override nonReentrant returns (uint256) {
        require(assets > 0, "ERC4626: zero deposit");
        require(
            assets <= maxDeposit(receiver),
            "ERC4626: deposit more than max"
        );
        uint256 shares = previewDeposit(assets);
        require(shares > 0, "ERC4626: zero shares mint");
        _deposit(_msgSender(), receiver, assets, shares);
        return shares;
    }

    /**
     * @dev Withdraws assets by burning shares.
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override nonReentrant returns (uint256) {
        require(assets > 0, "ERC4626: zero withdraw");
        require(
            assets <= maxWithdraw(owner),
            "ERC4626: withdraw more than max"
        );
        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return shares;
    }

    /**
     * @dev Handles deposits and mints corresponding shares.
     */
    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal override {
        SafeERC20.safeTransferFrom(
            IERC20(asset()),
            caller,
            address(this),
            assets
        );
        SuperlendAaveV3StrategyStorage
            storage $ = _getSuperlendAaveV3StrategyStorage();

        IERC20(asset()).approve(address($.pool), assets);
        $.pool.deposit(asset(), assets, address(this), 0);
        _mint(receiver, shares);
        emit Deposit(caller, receiver, assets, shares);
    }

    /**
     * @dev Handles withdrawals and burns shares.
     */
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }
        _burn(owner, shares);
        SuperlendAaveV3StrategyStorage
            storage $ = _getSuperlendAaveV3StrategyStorage();
        $.pool.withdraw(asset(), assets, address(this));
        SafeERC20.safeTransfer(IERC20(asset()), receiver, assets);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    /**
     * @dev Determines the maximum depositable assets.
     */
    function _maxDeposit() internal view returns (uint256) {
        SuperlendAaveV3StrategyStorage
            storage $ = _getSuperlendAaveV3StrategyStorage();
        DataTypes.ReserveData memory reserveData = $.pool.getReserveData(
            asset()
        );
        uint256 supplyCap = ReserveConfiguration.getSupplyCap(
            reserveData.configuration
        );
        uint256 maxAssetsDeposit = type(uint256).max;
        if (supplyCap != 0) {
            uint256 formattedSupplyCap = supplyCap *
                (10 **
                    ReserveConfiguration.getDecimals(
                        reserveData.configuration
                    ));
            uint256 totalAssetsSupplied = IAToken(reserveData.aTokenAddress)
                .scaledTotalSupply() +
                WadRayMath.rayMul(
                    reserveData.accruedToTreasury,
                    reserveData.liquidityIndex
                );
            maxAssetsDeposit = formattedSupplyCap - totalAssetsSupplied;
        }
        return maxAssetsDeposit;
    }
}
