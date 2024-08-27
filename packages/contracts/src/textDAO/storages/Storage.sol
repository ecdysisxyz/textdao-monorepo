// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {BaseSlots} from "bundle/textDAO/storages/BaseSlots.sol";

/**
 * @title StorageLib v0.1.0
 */
library Storage {
    bytes32 internal constant baseslot_Deliberation = BaseSlots.baseslot_Deliberation;
    bytes32 internal constant baseslot_Texts = BaseSlots.baseslot_Texts;
    bytes32 internal constant baseslot_Members = BaseSlots.baseslot_Members;
    bytes32 internal constant baseslot_Admins = BaseSlots.baseSlot_Admins;
    bytes32 internal constant baseslot_VRFStorage = BaseSlots.baseslot_VRFStorage;
    bytes32 internal constant baseslot_ConfigOverrideStorage = BaseSlots.baseslot_ConfigOverrideStorage;

    function Deliberation() internal pure returns (Schema.Deliberation storage $) {
        bytes32 slot = baseslot_Deliberation;
        assembly { $.slot := slot }
    }

    function Texts() internal pure returns (Schema.Texts storage $) {
        bytes32 slot = baseslot_Texts;
        assembly { $.slot := slot }
    }

    function Members() internal pure returns (Schema.Members storage $) {
        bytes32 slot = baseslot_Members;
        assembly { $.slot := slot }
    }

    function Admins() internal pure returns(Schema.Admins storage $) {
        bytes32 slot = baseslot_Admins;
        assembly { $.slot := slot }
    }

    function $VRF() internal pure returns (Schema.VRFStorage storage $) {
        bytes32 slot = baseslot_VRFStorage;
        assembly { $.slot := slot }
    }

    function $ConfigOverride() internal pure returns (Schema.ConfigOverrideStorage storage $) {
        bytes32 slot = baseslot_ConfigOverrideStorage;
        assembly { $.slot := slot }
    }
}
