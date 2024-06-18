// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title StorageSlot v0.1.0
 *
 * keccak256(abi.encode(uint256(keccak256("<corresponded URL in the Schema.sol>")) - 1)) & ~bytes32(uint256(0xff));
 */

library BaseSlots {
    bytes32 public constant baseslot_DAOState =
        0xe889cf6ef4c0b3e042bbf100ec9f5916e3cdbbc8d72066eb1501d905d151d000;
    bytes32 public constant baseslot_TextSaveProtectedStorage =
        0x00c2b62a56d6a36d26f9b1ee520f3f92694a04313c94e467f10a03b080d77900;
    bytes32 public constant baseslot_MemberJoinProtectedStorage =
        0x2909c0a05d58f8b7f14a4ef9b6dfbc139611bb545981c04988c895be90f35000;
    bytes32 public constant baseslot_VRFStorage =
        0xe4fa6871814422bfe1d10a118a3483c970f3cc6a461f81c9d5701005cfdaf400;
    bytes32 public constant baseslot_ConfigOverrideStorage =
        0x147a311fe1db87247fe76cc1e6db3134e5d52a59e0824f018dad572e05b14000;
}
