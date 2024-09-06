// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";

/**
 * @title DeliberationLib v0.1.0
 */
library DeliberationLib {
    function createProposal(Schema.Deliberation storage $deliberation) internal returns(Schema.Proposal storage $proposal) {
        $proposal = $deliberation.proposals.push();

        /// Note Avoid using index 0 of the array as it is reserved for the initial value.
        $proposal.headers.push();
        $proposal.cmds.push();

        $proposal.meta.createdAt = block.timestamp;
        $proposal.meta.expirationTime = block.timestamp + Storage.Deliberation().config.expiryDuration;
        $proposal.meta.snapInterval = Storage.Deliberation().config.snapInterval;
    }

    function getProposal(Schema.Deliberation storage $deliberation, uint pid) internal view returns(Schema.Proposal storage) {
        if ($deliberation.proposals.length <= pid) revert TextDAOErrors.ProposalNotFound();
        return $deliberation.proposals[pid];
    }
}


// Testing
import {MCTest, console2} from "@devkit/Flattened.sol";

contract DeliberationLibTest is MCTest {
    using DeliberationLib for Schema.Deliberation;

    function test_createProposal() public {
        vm.warp(1724116970);
        Storage.Deliberation().config.snapInterval = 1234567890;

        vm.record();
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        (, bytes32[] memory writes) = vm.accesses(
            address(this)
        );
        assertEq($proposal.headers.length, 1, "Headers array should be initialized with one element");
        assertEq($proposal.cmds.length, 1, "Commands array should be initialized with one element");
        assertEq($proposal.meta.createdAt, block.timestamp);
        assertEq($proposal.meta.expirationTime, block.timestamp + Storage.Deliberation().config.expiryDuration);
        assertEq($proposal.meta.snapInterval, Storage.Deliberation().config.snapInterval);
    }

    function test_createProposal_withoutLib() public {
        vm.record();
        Schema.Proposal storage proposal = Storage.Deliberation().proposals.push();
        proposal.headers.push();
        proposal.cmds.push();

        proposal.meta.createdAt = block.timestamp;
        (, bytes32[] memory writes) = vm.accesses(
            address(this)
        );

    }

}
