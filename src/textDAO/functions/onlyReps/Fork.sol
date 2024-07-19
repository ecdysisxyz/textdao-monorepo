// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyRepsBase} from "bundle/textDAO/functions/onlyReps/OnlyRepsBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {ProposalLib} from "bundle/textDAO/utils/ProposalLib.sol";
// Interface
import {IFork} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

/**
 * @title Fork function
 * @custom:version interface:0.1
 */
contract Fork is IFork, OnlyRepsBase {
    using ProposalLib for Schema.Proposal;

    function fork(uint pid, string calldata headerMetadataURI, Schema.Action[] calldata actions) external onlyReps(pid) {
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals[pid];

        if (bytes(headerMetadataURI).length > 0) {
            $proposal.createHeader(headerMetadataURI);
            emit TextDAOEvents.HeaderForked(pid, headerMetadataURI);
        }
        if (actions.length > 0) {
            $proposal.createCommand(actions);
            emit TextDAOEvents.CommandForked(pid, actions);
        }
        // Note: Shadow(sender, timestamp)
    }
}


import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

contract ForkTest is MCTest {

    function setUp() public {
        _use(Fork.fork.selector, address(new Fork()));
    }

    function test_fork_success() public {
        uint pid = 0;
        Schema.Proposal storage $p = Storage.Deliberation().proposals.push();

        assertEq($p.headers.length, 0);
        assertEq($p.cmds.length, 0);

        TestUtils.setMsgSenderAsRep(pid);
        Fork(target).fork({
            pid: pid,
            headerMetadataURI: "Qc.....xh",
            actions: new Schema.Action[](1)
        });

        assertEq($p.headers.length, 1);
        assertEq($p.cmds.length, 1);
    }

    function test_fork_revert_notRep() public {
        Storage.Deliberation().proposals.push();

        vm.expectRevert(TextDAOErrors.YouAreNotTheRep.selector);
        Fork(target).fork({
            pid: 0,
            headerMetadataURI: "Qc.....xh",
            actions: new Schema.Action[](1)
        });
    }

}
