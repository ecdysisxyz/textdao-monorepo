// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "./Schema.sol";
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";

/**
 * @title HubDAO StorageLib v0.1.0
 */
library Storage {
    /// @notice Returns the storage location for DaoTemplates
    function DaoTemplates() internal pure returns (Schema.DaoTemplates storage $) {
        assembly { $.slot := 0x76fb4d6b14c8f593e8096b2efefe8bdb3bf6608242c6223dec70e29e3d6c8800 }
    }

    /// @notice Returns the storage location for DaoRegistry
    function DaoRegistry() internal pure returns (Schema.DaoRegistry storage $) {
        assembly { $.slot := 0xe5d7da768dcffdf84391b9364b8c9bdf8f04c505b8f66f903ae674158b851e00 }
    }

    /// @notice Returns the storage location for GlobalConfigs
    function GlobalConfigs() internal pure returns(Schema.GlobalConfigs storage $) {
        assembly { $.slot := 0x666abab1bf2ddddf65ea5ff23d9a5c3195486a976b6248003027297496fcce00 }
    }

    /// @custom:storage-location erc7201:HubDAO.TextDAO.DefaultDeliberationConfig
    /// @notice Returns the storage location for TextDaoDefaultConfig
    function TextDaoDefaultConfig() internal pure returns(TextDAOSchema.DeliberationConfig storage $) {
        assembly { $.slot := 0x0f39206e721bfc5bd124622b34f0016175cf9caa382768980d7d45d55b7d6b00 }
    }

    /// @notice Returns the storage location for Admins
    function Admins() internal pure returns (Schema.Admins storage $) {
        assembly { $.slot := 0x882b195febac099684e48411bd407759354f3603a7bf2b0aa239f54a6ab23b00 }
    }
}

// // Testing
// import {Test} from "forge-std/Test.sol";

// contract StorageTest is Test {
//     /// @notice Test to ensure that Storage base slots are unique
//     function test_storageBaseSlotsUnique() public {
//         bytes32[] memory slots = new bytes32[](5);

//         // Get the base slots directly from the Storage library functions
//         slots[0] = getSlotDaoTemplates();
//         slots[1] = getSlotDaoRegistry();
//         slots[2] = getSlotGlobalConfigs();
//         slots[3] = getSlotTextDaoDefaultConfig();
//         slots[4] = getSlotAdmins();

//         // Check that all base slots are unique
//         for (uint i = 0; i < slots.length; i++) {
//             for (uint j = i + 1; j < slots.length; j++) {
//                 assertTrue(slots[i] != slots[j], string(abi.encodePacked("Base slot at index ", vm.toString(i), " is not unique")));
//             }
//         }
//     }

//     /// @notice Helper function to get the storage slot for DaoTemplates
//     function getSlotDaoTemplates() internal pure returns (bytes32 slot) {
//         assembly {
//             slot := Storage.DaoTemplates.slot
//         }
//     }

//     /// @notice Helper function to get the storage slot for DaoRegistry
//     function getSlotDaoRegistry() internal pure returns (bytes32 slot) {
//         assembly {
//             slot := Storage.DaoRegistry.slot
//         }
//     }

//     /// @notice Helper function to get the storage slot for GlobalConfigs
//     function getSlotGlobalConfigs() internal pure returns (bytes32 slot) {
//         assembly {
//             slot := Storage.GlobalConfigs.slot
//         }
//     }

//     /// @notice Helper function to get the storage slot for TextDaoDefaultConfig
//     function getSlotTextDaoDefaultConfig() internal pure returns (bytes32 slot) {
//         assembly {
//             slot := Storage.TextDaoDefaultConfig.slot
//         }
//     }

//     /// @notice Helper function to get the storage slot for Admins
//     function getSlotAdmins() internal pure returns (bytes32 slot) {
//         assembly {
//             slot := Storage.Admins.slot
//         }
//     }
// }
