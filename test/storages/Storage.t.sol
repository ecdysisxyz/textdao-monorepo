// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {Storage} from "bundle/textdao/storages/Storage.sol";
import {BaseSlots} from "bundle/textdao/storages/BaseSlots.sol";

contract StorageTest is MCTest {

    function test_DAOState() public {
        vm.record();
        Storage.DAOState().proposals.push();
        Storage.DAOState().config.expiryDuration = 10;
        Storage.DAOState().config.tallyInterval = 20;
        Storage.DAOState().config.repsNum = 30;
        Storage.DAOState().config.quorumScore = 40;
        (, bytes32[] memory writes) = vm.accesses(
            address(this)
        );

        // proposals
        bytes32 DAOState_proposals_baseSlot = bytes32(uint256(BaseSlots.baseslot_DAOState)+0);
        bytes32 DAOState_proposals_length_slot = bytes32(uint256(DAOState_proposals_baseSlot)+0);
        assertEq(writes[0], DAOState_proposals_length_slot);
        assertEq(uint256(vm.load(address(this), DAOState_proposals_length_slot)), 1);

        // config
        bytes32 DAOState_config_baseSlot = bytes32(uint256(BaseSlots.baseslot_DAOState)+1);
        bytes32 DAOState_config_expiryDuration_slot = bytes32(uint256(DAOState_config_baseSlot)+0);
        bytes32 DAOState_config_tallyInternal_slot = bytes32(uint256(DAOState_config_baseSlot)+1);
        bytes32 DAOState_config_repsNum_slot = bytes32(uint256(DAOState_config_baseSlot)+2);
        bytes32 DAOState_config_quorumScore_slot = bytes32(uint256(DAOState_config_baseSlot)+3);
        assertEq(writes[1], DAOState_config_expiryDuration_slot);
        assertEq(uint256(vm.load(address(this), DAOState_config_expiryDuration_slot)), 10);
        assertEq(writes[2], DAOState_config_tallyInternal_slot);
        assertEq(uint256(vm.load(address(this), DAOState_config_tallyInternal_slot)), 20);
        assertEq(writes[3], DAOState_config_repsNum_slot);
        assertEq(uint256(vm.load(address(this), DAOState_config_repsNum_slot)), 30);
        assertEq(writes[4], DAOState_config_quorumScore_slot);
        assertEq(uint256(vm.load(address(this), DAOState_config_quorumScore_slot)), 40);
    }

}
