// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "./Schema.sol";
import {BaseSlots} from "bundle/textdao/storages/BaseSlots.sol";

/**
 * @title HubDAO StorageLib v0.1.0
 */
library Storage {
    function MetaState() internal pure returns (Schema.MetaState storage $) {
        assembly { $.slot := 0x5f2feac51ab9a9317522c3163b69ac30ee19f150fd622825e733d084948fc500 }
    }

    function DaoRegistry() internal pure returns (Schema.DaoRegistry storage $) {
        assembly { $.slot := 0xe5d7da768dcffdf84391b9364b8c9bdf8f04c505b8f66f903ae674158b851e00 }
    }

    function Admins() internal pure returns (Schema.Admins storage $) {
        assembly { $.slot := 0x882b195febac099684e48411bd407759354f3603a7bf2b0aa239f54a6ab23b00 }
    }

}
