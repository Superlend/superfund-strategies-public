// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title SuperlendAaveV3StrategyBase
 * @author Superlend
 * @notice Base contract of Aave Strategy for Euler Earn.
 *         This contract contains the storage-related actions
 *         for the contract.
 * @dev Designed this way to enable easier contract upgrades.
 */
abstract contract SuperlendAaveV3StrategyBase {
    /**
     * @dev Storage structure for the Aave V3 strategy.
     * @custom:storage-location erc7201:superlend.storage.AaveV3Strategy
     */
    struct SuperlendAaveV3StrategyStorage {
        IPool pool; // Reference to the Aave V3 lending pool.
        IERC20 aToken; // Aave interest-bearing token associated with the strategy.
    }

    /**
     * @dev Storage location constant for the Aave V3 strategy storage.
     * Computed using: keccak256(abi.encode(uint256(keccak256("superlend.storage.AaveV3Strategy")) - 1)) & ~bytes32(uint256(0xff))
     */
    bytes32 private constant SuperlendAaveV3StrategyStorageLocation =
        0x13f5fde811b79be108014a1c42f5135cc48193b4f7a33c22c0addba54a38c300;

    /**
     * @notice Retrieves the storage struct pointer for the Aave V3 strategy.
     * @dev Uses assembly to return a reference to the strategy storage.
     * @return $ Storage reference to the strategy data.
     */
    function _getSuperlendAaveV3StrategyStorage()
        internal
        pure
        returns (SuperlendAaveV3StrategyStorage storage $)
    {
        assembly {
            $.slot := SuperlendAaveV3StrategyStorageLocation
        }
    }
}
