// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import { Storage } from "bundle/textdao/storages/Storage.sol";
import { BaseSlots } from "bundle/textdao/storages/BaseSlots.sol";

contract StorageTest is MCTest {

    function test_ProposeStorage() public {
        vm.record();
        Storage.$Proposals().nextProposalId = 1;
        (, bytes32[] memory writes) = vm.accesses(
            address(this)
        );

        bytes32 SLOT_ProposeStorage_nextProposal = bytes32(uint256(BaseSlots.baseslot_ProposeStorage)+1);
        assertEq(writes[0], SLOT_ProposeStorage_nextProposal);
        assertEq(
            uint256(vm.load(address(this), SLOT_ProposeStorage_nextProposal)),
            1
        );
    }

}
