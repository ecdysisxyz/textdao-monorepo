// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "./Schema.sol";
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";

/**
 * @title HubDAO StorageLib v0.1.0
 */
library Storage {
    function DaoTemplates() internal pure returns (Schema.DaoTemplates storage $) {
        assembly { $.slot := 0x76fb4d6b14c8f593e8096b2efefe8bdb3bf6608242c6223dec70e29e3d6c8800 }
    }

    function DaoRegistry() internal pure returns (Schema.DaoRegistry storage $) {
        assembly { $.slot := 0xe5d7da768dcffdf84391b9364b8c9bdf8f04c505b8f66f903ae674158b851e00 }
    }

    function GlobalConfigs() internal pure returns(Schema.GlobalConfigs storage $) {
        assembly { $.slot := 0x666abab1bf2ddddf65ea5ff23d9a5c3195486a976b6248003027297496fcce00 }
    }

    /// @custom:storage-location erc7201:HubDAO.TextDAO.DefaultDeliberationConfig
    function TextDaoDefaultConfig() internal pure returns(TextDAOSchema.DeliberationConfig storage $) {
        assembly { $.slot := 0x0f39206e721bfc5bd124622b34f0016175cf9caa382768980d7d45d55b7d6b00 }
    }

    function Admins() internal pure returns (Schema.Admins storage $) {
        assembly { $.slot := 0x882b195febac099684e48411bd407759354f3603a7bf2b0aa239f54a6ab23b00 }
    }

}
