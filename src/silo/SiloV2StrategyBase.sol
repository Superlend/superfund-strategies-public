// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ISilo} from "silo-contracts-v2/silo-core/contracts/interfaces/ISilo.sol";

/**
 * @title SuperlendSiloV2StrategyBase
 * @author Superlend
 * @notice Base contract for the Silo V2 Strategy in Silo Earn.
 *         This contract manages storage-related actions
 *         for the strategy.
 * @dev Designed this way to enable easier contract upgrades.
 */
abstract contract SuperlendSiloV2StrategyBase {
    /// @custom:storage-location erc7201:superlend.storage.SiloV2Strategy
    struct SuperlendSiloV2StrategyStorage {
        ISilo silo;
    }

    // keccak256(abi.encode(uint256(keccak256("superlend.storage.SiloV2Strategy")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant SuperlendSiloV2StrategyStorageLocation =
        0x973a9dc661de66a01865ba39d75a625bc7862528f0a0c105a98db5ea5553ff00;

    /**
     * @dev Retrieves storage struct pointer.
     */
    function _getSuperlendSiloV2StrategyStorage()
        internal
        pure
        returns (SuperlendSiloV2StrategyStorage storage $)
    {
        assembly {
            $.slot := SuperlendSiloV2StrategyStorageLocation
        }
    }
}
