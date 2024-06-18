// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import { Storage } from "bundle/textdao/storages/Storage.sol";
import { BaseSlots } from "bundle/textdao/storages/BaseSlots.sol";

contract StorageTest is MCTest {

    function test_ProposeStorage() public {
        vm.record();
        Storage.DAOState().nextProposalId = 1;
        (, bytes32[] memory writes) = vm.accesses(
            address(this)
        );

        bytes32 SLOT_DAOState_nextProposal = bytes32(uint256(BaseSlots.baseslot_DAOState)+1);
        assertEq(writes[0], SLOT_DAOState_nextProposal);
        assertEq(
            uint256(vm.load(address(this), SLOT_DAOState_nextProposal)),
            1
        );
    }

}
