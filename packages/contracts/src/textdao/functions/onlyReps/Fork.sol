// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyRepsBase} from "bundle/textdao/functions/onlyReps/OnlyRepsBase.sol";
// Storage
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {ProposalLib} from "bundle/textdao/utils/ProposalLib.sol";
// Interface
import {IFork} from "bundle/textdao/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";

/**
 * @title Fork function
 * @dev Allows representatives to fork an existing proposal by adding new headers or commands
 * @custom:version 0.1.0
 */
contract Fork is IFork, OnlyRepsBase {
    using ProposalLib for Schema.Proposal;

    /**
     * @notice Forks an existing proposal by adding a new header or command
     * @param pid The ID of the proposal to fork
     * @param headerMetadataCid The content id for the new header metadata (can be empty)
     * @param actions The array of actions for the new command (can be empty)
     */
    function fork(uint pid, string calldata headerMetadataCid, Schema.Action[] calldata actions) external onlyReps(pid) {
        _forkHeader(pid, headerMetadataCid);
        _forkCommand(pid, actions);
    }

    function forkHeader(uint pid, string calldata headerMetadataCid) external onlyReps(pid) {
        _forkHeader(pid, headerMetadataCid);
    }

    function forkCommand(uint pid, Schema.Action[] calldata actions) external onlyReps(pid) {
        _forkCommand(pid, actions);
    }

    function _forkHeader(uint pid, string calldata headerMetadataCid) internal {
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals[pid];
        if (bytes(headerMetadataCid).length > 0) {
            uint _headerId = $proposal.createHeader(headerMetadataCid);
            emit TextDAOEvents.HeaderCreated(pid, _headerId, headerMetadataCid);
        }
    }

    function _forkCommand(uint pid, Schema.Action[] calldata actions) internal {
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals[pid];
        if (actions.length > 0) {
            uint _cmdId = $proposal.createCommand(actions);
            emit TextDAOEvents.CommandCreated(pid, _cmdId, actions);
        }
    }

}


// Testing
import {MCTest} from "@devkit/Flattened.sol";
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";

/**
 * @title ForkTest
 * @dev Test contract for the Fork functionality in TextDAO
 */
contract ForkTest is MCTest {
    using DeliberationLib for Schema.Deliberation;

    function setUp() public {
        _use(Fork.fork.selector, address(new Fork()));
    }

    /**
     * @notice Test successful forking of a proposal with both header and command
     * @dev Verifies that a new header and command are added correctly and proper events are emitted
     */
    function test_fork_success() public {
        uint pid = 0;
        Schema.Proposal storage $p = Storage.Deliberation().createProposal();

        // Assert initial state
        assertEq($p.headers.length, 1, "Initial headers length should be 1");
        assertEq($p.cmds.length, 1, "Initial commands length should be 1");

        TestUtils.setMsgSenderAsRep(pid);

        // Expect correct events to be emitted
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(pid, 1, "Qc.....xh");
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.CommandCreated(pid, 1, new Schema.Action[](1));

        Fork(target).fork({
            pid: pid,
            headerMetadataCid: "Qc.....xh",
            actions: new Schema.Action[](1)
        });

        // Assert final state after forking
        assertEq($p.headers.length, 2, "Headers length should be 2 after forking");
        assertEq($p.cmds.length, 2, "Commands length should be 2 after forking");
    }

    /**
     * @notice Test successful forking of a proposal with only a new header
     * @dev Verifies that only a new header is added and the proper event is emitted
     */
    function test_fork_success_onlyHeader() public {
        uint pid = 0;
        Schema.Proposal storage $p = Storage.Deliberation().createProposal();

        TestUtils.setMsgSenderAsRep(pid);

        // Expect correct event to be emitted
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(pid, 1, "Qc.....xh");

        Fork(target).fork({
            pid: pid,
            headerMetadataCid: "Qc.....xh",
            actions: new Schema.Action[](0)
        });

        // Assert final state after forking
        assertEq($p.headers.length, 2, "Headers length should be 2 after forking");
        assertEq($p.cmds.length, 1, "Commands length should remain 1");
    }

    /**
     * @notice Test successful forking of a proposal with only a new command
     * @dev Verifies that only a new command is added and the proper event is emitted
     */
    function test_fork_success_onlyCommand() public {
        uint pid = 0;
        Schema.Proposal storage $p = Storage.Deliberation().createProposal();

        TestUtils.setMsgSenderAsRep(pid);

        // Expect correct event to be emitted
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.CommandCreated(pid, 1, new Schema.Action[](1));

        Fork(target).fork({
            pid: pid,
            headerMetadataCid: "",
            actions: new Schema.Action[](1)
        });

        // Assert final state after forking
        assertEq($p.headers.length, 1, "Headers length should remain 1");
        assertEq($p.cmds.length, 2, "Commands length should be 2 after forking");
    }

    /**
     * @notice Test that non-representatives cannot fork a proposal
     * @dev Verifies that the onlyReps modifier is working correctly
     */
    function test_fork_revert_notRep() public {
        Storage.Deliberation().proposals.push();

        vm.expectRevert(TextDAOErrors.YouAreNotTheRep.selector);
        Fork(target).fork({
            pid: 0,
            headerMetadataCid: "Qc.....xh",
            actions: new Schema.Action[](1)
        });
    }
}
