// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SuperlendEulerV2StrategyBase} from "./EulerV2StrategyBase.sol";
import {Initializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";
import {ERC4626Upgradeable, Math} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {IEVault} from "euler-vault-kit/EVault/IEVault.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title SuperlendEulerV2Strategy
 * @author Superlend
 * @notice An ERC4626-compliant vault that interfaces with Euler V2 vault.
 *         This contract serves as an adapter between the Euler V2 vault and
 *         the Superlend curated vault on the Euler Earn interface.
 * @dev Implements the ERC4626 standard.
 */
contract SuperlendEulerV2Strategy is
    SuperlendEulerV2StrategyBase,
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
     * @param vault_ Address of the Euler vault.
     */
    function initialize(
        string memory name_,
        string memory symbol_,
        address asset_,
        address vault_
    ) public initializer {
        __ERC4626_init_unchained(IERC20(asset_));
        __ERC20_init_unchained(name_, symbol_);
        __ReentrancyGuard_init_unchained();
        __SuperlendEulerV2Strategy_init(vault_);
    }

    /**
     * @dev Internal initialization function.
     */
    function __SuperlendEulerV2Strategy_init(
        address vault_
    ) internal onlyInitializing {
        SuperlendEulerV2StrategyStorage
            storage $ = _getSuperlendEulerV2StrategyStorage();

        $.vault = IEVault(vault_);
    }

    /**
     * @notice Returns the total assets managed by the vault.
     */
    function totalAssets() public view override returns (uint256) {
        SuperlendEulerV2StrategyStorage
            storage $ = _getSuperlendEulerV2StrategyStorage();

        return $.vault.maxWithdraw(address(this));
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
        SuperlendEulerV2StrategyStorage
            storage $ = _getSuperlendEulerV2StrategyStorage();

        IERC20(asset()).approve(address($.vault), assets);
        $.vault.deposit(assets, address(this));

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
        SuperlendEulerV2StrategyStorage
            storage $ = _getSuperlendEulerV2StrategyStorage();

        $.vault.withdraw(assets, address(this), address(this));

        SafeERC20.safeTransfer(IERC20(asset()), receiver, assets);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }

    /**
     * @dev Determines the maximum depositable assets.
     */
    function _maxDeposit() internal view returns (uint256) {
        SuperlendEulerV2StrategyStorage
            storage $ = _getSuperlendEulerV2StrategyStorage();

        return $.vault.maxDeposit(address(this));
    }
}
