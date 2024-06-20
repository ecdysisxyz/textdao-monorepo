// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title StorageSlot v0.1.0
 *
 * keccak256(abi.encode(uint256(keccak256("<corresponded URL in the Schema.sol>")) - 1)) & ~bytes32(uint256(0xff));
 */

library BaseSlots {
    bytes32 public constant baseslot_Deliberation =
        0x51e64ee84f491aad402ff73401b25fa2058a87e9d027403050c951c19bbb7800;
    bytes32 public constant baseslot_Texts =
        0x1936e448f24d50cf45d061362b8b2abea6f76fd415e7ceb5fe96d540deb60400;
    bytes32 public constant baseslot_Members =
        0x8972abadfc8727f472fb0b6beb8d30155bd57415f49dc6c94e9cecdec0ed9200;
    bytes32 public constant baseslot_VRFStorage =
        0xbacc45d94f3c311c83de7e11ee1a81c3735ba264fe339411bbcc7be5e4317d00;
    bytes32 public constant baseslot_ConfigOverrideStorage =
        0x147a311fe1db87247fe76cc1e6db3134e5d52a59e0824f018dad572e05b14000;
}
