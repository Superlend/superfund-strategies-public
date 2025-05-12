// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IEVault} from "euler-vault-kit/EVault/IEVault.sol";

/**
 * @title SuperlendEulerV2StrategyBase
 * @author Superlend
 * @notice Base contract for the Euler V2 Strategy in Euler Earn.
 *         This contract manages storage-related actions
 *         for the strategy.
 * @dev Designed this way to enable easier contract upgrades.
 */
abstract contract SuperlendEulerV2StrategyBase {
    /// @custom:storage-location erc7201:superlend.storage.EulerV2Strategy
    struct SuperlendEulerV2StrategyStorage {
        IEVault vault;
    }

    // keccak256(abi.encode(uint256(keccak256("superlend.storage.EulerV2Strategy")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant SuperlendEulerV2StrategyStorageLocation =
        0x4a5a06b7b76b28fb29b4d45983612cbcf1cd522d7b02db0c37cf799f3ce80100;

    /**
     * @dev Retrieves storage struct pointer.
     */
    function _getSuperlendEulerV2StrategyStorage()
        internal
        pure
        returns (SuperlendEulerV2StrategyStorage storage $)
    {
        assembly {
            $.slot := SuperlendEulerV2StrategyStorageLocation
        }
    }
}
