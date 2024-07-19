// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

/**
 * @title ProposalLib
 * @dev Library for managing proposals in TextDAO
 * @notice This library provides functions to create, modify, and query proposal data
 * @custom:version 0.1.0
 */
library ProposalLib {
    /**
     * @notice Creates a new header for a proposal
     * @param $proposal The proposal to add the header to
     * @param metadataURI The URI of the metadata for the header
     * @dev Initializes a new header with zero score and empty tag list
     */
    function createHeader(Schema.Proposal storage $proposal, string memory metadataURI) internal {
        $proposal.headers.push(Schema.Header({
            currentScore: 0,
            metadataURI: metadataURI,
            tagIds: new uint[](0)
        }));
    }

    /**
     * @notice Creates a new command for a proposal
     * @param $proposal The proposal to add the command to
     * @param actions The actions to be included in the command
     * @dev Initializes a new command with the given actions and zero score
     */
    function createCommand(Schema.Proposal storage $proposal, Schema.Action[] memory actions) internal {
        Schema.Command storage $cmd = $proposal.cmds.push();
        for (uint i; i < actions.length; ++i) {
            $cmd.actions.push(actions[i]);
        }
        /// @dev ActionStatus defaults to 'Proposed' (0) when creating a Command, so it doesn't need to be explicitly set.
        $cmd.currentScore = 0;
    }

    /**
     * @notice Checks if a proposal has expired
     * @param $proposal The proposal to check
     * @return bool True if the proposal has expired, false otherwise
     * @dev Compares the current block timestamp with the proposal's expiration time
     */
    function isExpired(Schema.Proposal storage $proposal) internal view returns(bool) {
        return $proposal.meta.expirationTime < block.timestamp;
    }

    /**
     * @notice Calculates the current epoch for a proposal
     * @param $proposal The proposal to calculate the epoch for
     * @return uint256 The current epoch
     * @dev Returns 1 if snap interval is 0, otherwise calculates based on current timestamp
     */
    function calcCurrentEpoch(Schema.Proposal storage $proposal) internal view returns(uint256) {
        uint256 _snapInterval = $proposal.meta.snapInterval;
        if (_snapInterval == 0) return 1;
        return block.timestamp / _snapInterval * _snapInterval;
    }

    /**
     * @notice Checks if a proposal has been snapped in the current epoch
     * @param $proposal The proposal to check
     * @return bool True if the proposal has been snapped in the current epoch, false otherwise
     */
    function isSnappedInEpoch(Schema.Proposal storage $proposal) internal view returns(bool) {
        return $proposal.meta.snapped[calcCurrentEpoch($proposal)];
    }

    /**
     * @notice Flags a proposal as snapped in the current epoch
     * @param $proposal The proposal to flag
     * @dev Sets the snapped status for the current epoch to true
     */
    function flagSnappedInEpoch(Schema.Proposal storage $proposal) internal {
        $proposal.meta.snapped[calcCurrentEpoch($proposal)] = true;
    }

    /**
    * @notice Approves a specific header in the proposal
    * @param $proposal The proposal to update
    * @param headerIdForApproval The ID of the header to approve
     * @dev Reverts if the header ID is invalid (0 or out of bounds)
    */
    function approveHeader(Schema.Proposal storage $proposal, uint headerIdForApproval) internal {
        if (headerIdForApproval == 0 ||
            headerIdForApproval >= $proposal.headers.length
        ) revert TextDAOErrors.InvalidHeaderId(headerIdForApproval);
        $proposal.meta.approvedHeaderId = headerIdForApproval;
    }

    /**
    * @notice Approves a specific command and its actions in the proposal
    * @param $proposal The proposal to update
    * @param cmdIdForApproval The ID of the command to approve
    * @dev Reverts if the command ID is invalid
    */
    function approveCommand(Schema.Proposal storage $proposal, uint cmdIdForApproval) internal {
        if (cmdIdForApproval == 0 ||
            cmdIdForApproval >= $proposal.cmds.length
        ) revert TextDAOErrors.InvalidCommandId(cmdIdForApproval);

        $proposal.meta.approvedCommandId = cmdIdForApproval;
        Schema.Action[] storage $actions = $proposal.cmds[cmdIdForApproval].actions;
        for (uint i; i < $actions.length; ++i) {
            $proposal.meta.actionStatuses[i] = Schema.ActionStatus.Approved;
        }
    }

    /**
     * @notice Checks if a proposal has been approved
     * @param $proposal The proposal to check
     * @return bool True if the proposal has been approved, false otherwise
     * @dev A proposal is considered approved if either a header or a command has been approved
     */
    function isApproved(Schema.Proposal storage $proposal) internal view returns(bool) {
        return (
            $proposal.meta.approvedHeaderId != 0 ||
            $proposal.meta.approvedCommandId != 0
        );
    }
}


/// Testing
import {Test} from "@devkit/Flattened.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";

/**
 * @title ProposalLibTest
 * @dev Test contract for the ProposalLib library
 */
contract ProposalLibTest is Test {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;

    /// @notice Tests the creation of a new header in a proposal
    /// @dev Verifies that a header is correctly added with the specified metadata
    function test_createHeader_success() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        uint _initialLength = $testProposal.headers.length;
        $testProposal.createHeader("test://metadata");
        assertEq($testProposal.headers.length, _initialLength + 1, "Should have added one header");
        assertEq($testProposal.headers[_initialLength].metadataURI, "test://metadata", "Metadata URI should match");
        assertEq($testProposal.headers[_initialLength].currentScore, 0, "Initial score should be zero");
        assertEq($testProposal.headers[_initialLength].tagIds.length, 0, "Tag IDs should be empty");
    }

    /// @notice Tests the creation of a new command in a proposal
    /// @dev Verifies that a command is correctly added with the specified actions
    function test_createCommand_success() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        uint _initialLength = $testProposal.cmds.length;
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action("test()", "0x");
        $testProposal.createCommand(_actions);
        assertEq($testProposal.cmds.length, _initialLength + 1, "Should have added one command");
        assertEq($testProposal.cmds[_initialLength].actions.length, 1, "Should have 1 action");
        assertEq($testProposal.cmds[_initialLength].currentScore, 0, "Initial score should be zero");
    }

    /// @notice Tests the expiration status of a proposal
    /// @dev Verifies that a proposal is correctly marked as expired after its expiration time
    function test_isExpired_success() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        $testProposal.meta.expirationTime = block.timestamp + 1 hours;
        assertFalse($testProposal.isExpired(), "Proposal should not be expired");

        vm.warp(block.timestamp + 2 hours);
        assertTrue($testProposal.isExpired(), "Proposal should be expired");
    }

    /**
     * @notice Tests the calculation of current epoch
     * @dev Verifies that the current epoch is correctly calculated based on the snap interval
     */
    function test_calcCurrentEpoch_success() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        $testProposal.meta.snapInterval = 1 hours;
        vm.warp(5 hours);
        assertEq($testProposal.calcCurrentEpoch(), 5 hours, "Current epoch should be 5 hours");
    }

    /**
     * @notice Tests the snapping functionality of a proposal in an epoch
     * @dev Verifies that a proposal can be correctly flagged as snapped and that the status is properly recorded
     */
    function test_isSnappedInEpoch_success() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        $testProposal.meta.snapInterval = 1 hours;
        vm.warp(5 hours);
        assertFalse($testProposal.isSnappedInEpoch(), "Should not be snapped initially");
        $testProposal.flagSnappedInEpoch();
        assertTrue($testProposal.isSnappedInEpoch(), "Should be snapped after flagging");
    }

    /// @notice Tests the approval of a header in a proposal
    /// @dev Verifies that a header can be approved and that invalid header IDs are rejected
    function test_approveHeader_success() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        $testProposal.createHeader("test://metadata1");
        $testProposal.createHeader("test://metadata2");
        $testProposal.approveHeader(1);
        assertEq($testProposal.meta.approvedHeaderId, 1, "Header 1 should be approved");

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidHeaderId.selector, 0));
        $testProposal.approveHeader(0);

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidHeaderId.selector, 3));
        $testProposal.approveHeader(3);
    }

    function test_approveHeader_revert_invalidId() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        $testProposal.createHeader("test://metadata1");
        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidHeaderId.selector, 0));
        $testProposal.approveHeader(0);

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidHeaderId.selector, 2));
        $testProposal.approveHeader(2);
    }

    /// @notice Tests the approval of a command in a proposal
    /// @dev Verifies that a command can be approved and that invalid command IDs are rejected
    function test_approveCommand_success() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action("test()", "0x");
        $testProposal.createCommand(_actions);
        $testProposal.approveCommand(1);
        assertEq($testProposal.meta.approvedCommandId, 1, "Command 1 should be approved");
        assertEq(uint($testProposal.meta.actionStatuses[0]), uint(Schema.ActionStatus.Approved), "Action should be approved");

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidCommandId.selector, 0));
        $testProposal.approveCommand(0);

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidCommandId.selector, 2));
        $testProposal.approveCommand(2);
    }

    function test_approveCommand_revert_invalidId() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action("test()", "0x");
        $testProposal.createCommand(_actions);
        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidCommandId.selector, 0));
        $testProposal.approveCommand(0);

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidCommandId.selector, 2));
        $testProposal.approveCommand(2);
    }

    /// @notice Tests the overall approval status of a proposal
    /// @dev Verifies that a proposal is correctly marked as approved after a header is approved
    function test_isApproved_success() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        assertFalse($testProposal.isApproved(), "New proposal should not be approved");
        $testProposal.meta.approvedHeaderId = 1;
        assertTrue($testProposal.isApproved(), "Proposal should be approved after header approval");
    }
}
