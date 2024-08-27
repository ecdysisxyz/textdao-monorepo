// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {BaseSlots} from "bundle/textDAO/storages/BaseSlots.sol";

contract StorageTest is MCTest {
    function _erc7201(string memory namespace) internal returns(bytes32) {
        return keccak256(abi.encode(uint256(keccak256(bytes(namespace))) - 1)) & ~bytes32(uint256(0xff));
    }
    function test_baseSlots() public {
        assertEq(BaseSlots.baseslot_Deliberation, _erc7201("textDAO.Deliberation"));
        assertEq(BaseSlots.baseslot_Texts, _erc7201("textDAO.Texts"));
        assertEq(BaseSlots.baseslot_Members, _erc7201("textDAO.Members"));
        assertEq(BaseSlots.baseslot_VRFStorage, _erc7201("textDAO.VRFStorage"));
    }

    function test_Deliberation() public {
        vm.record();
        Storage.Deliberation().proposals.push();
        Storage.Deliberation().config.expiryDuration = 10;
        Storage.Deliberation().config.snapInterval = 20;
        Storage.Deliberation().config.repsNum = 30;
        Storage.Deliberation().config.quorumScore = 40;
        (, bytes32[] memory writes) = vm.accesses(
            address(this)
        );

        // proposals
        bytes32 Deliberation_proposals_baseSlot = bytes32(uint256(BaseSlots.baseslot_Deliberation)+0);
        bytes32 Deliberation_proposals_length_slot = bytes32(uint256(Deliberation_proposals_baseSlot)+0);
        assertEq(writes[0], Deliberation_proposals_length_slot);
        assertEq(uint256(vm.load(address(this), Deliberation_proposals_length_slot)), 1);

        // config
        bytes32 Deliberation_config_baseSlot = bytes32(uint256(BaseSlots.baseslot_Deliberation)+1);
        bytes32 Deliberation_config_expiryDuration_slot = bytes32(uint256(Deliberation_config_baseSlot)+0);
        bytes32 Deliberation_config_tallyInternal_slot = bytes32(uint256(Deliberation_config_baseSlot)+1);
        bytes32 Deliberation_config_repsNum_slot = bytes32(uint256(Deliberation_config_baseSlot)+2);
        bytes32 Deliberation_config_quorumScore_slot = bytes32(uint256(Deliberation_config_baseSlot)+3);
        assertEq(writes[1], Deliberation_config_expiryDuration_slot);
        assertEq(uint256(vm.load(address(this), Deliberation_config_expiryDuration_slot)), 10);
        assertEq(writes[2], Deliberation_config_tallyInternal_slot);
        assertEq(uint256(vm.load(address(this), Deliberation_config_tallyInternal_slot)), 20);
        assertEq(writes[3], Deliberation_config_repsNum_slot);
        assertEq(uint256(vm.load(address(this), Deliberation_config_repsNum_slot)), 30);
        assertEq(writes[4], Deliberation_config_quorumScore_slot);
        assertEq(uint256(vm.load(address(this), Deliberation_config_quorumScore_slot)), 40);
    }

}
