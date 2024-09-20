// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textdao/utils/CommandLib.sol";
import {IExecute} from "bundle/textdao/interfaces/TextDAOFunctions.sol";
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";

/**
 * @title Execute
 * @dev Implements the batch execution logic for approved proposals in TextDAO
 */
contract Execute is IExecute {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Action;

    /**
     * @notice Executes all unexecuted actions in the approved command for a given proposal
     * @param pid The ID of the proposal to execute
     * @dev This function will revert if the proposal is not approved, already fully executed, or if any action fails
     */
    function execute(uint pid) external {
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);
        uint _approvedCommandId = $proposal.meta.approvedCommandId;

        if (_approvedCommandId == 0) revert TextDAOErrors.ProposalNotApproved();
        if ($proposal.meta.fullyExecuted) revert TextDAOErrors.ProposalAlreadyFullyExecuted();

        Schema.Action[] storage $actions = $proposal.cmds[_approvedCommandId].actions;
        uint _actionsLength = $actions.length;
        if (_actionsLength == 0) revert TextDAOErrors.NoActionToBeExecuted();
        uint _executedCount = 0;

        for (uint i; i < _actionsLength; ++i) {
            if ($proposal.meta.actionStatuses[i] == Schema.ActionStatus.Executed) {
                _executedCount++;
                continue;
            }
            (bool success, ) = address(this).call($actions[i].calcCallData());

            if (!success) {
                revert TextDAOErrors.ActionExecutionFailed(i);
            }
            _executedCount++;
        }

        if (_executedCount == _actionsLength) {
            $proposal.meta.fullyExecuted = true;
            emit TextDAOEvents.ProposalExecuted(pid, _approvedCommandId);
        }
    }
}


// Testing
import {MCTest, VmSafe, console} from "@mc-devkit/Flattened.sol";
import {ProtectionBase} from "bundle/textdao/functions/protected/ProtectionBase.sol";

contract ExecuteTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Command;

    function setUp() public {
        _use(Execute.execute.selector, address(new Execute()));
    }

    function test_execute_success() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAction("successFunction(uint256)", abi.encode(uint(0)));
        $cmd.createAction("successFunction(uint256)", abi.encode(uint(0)));
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;
        $proposal.meta.actionStatuses[1] = Schema.ActionStatus.Approved;

        address _successContract = address(new SuccessContract());
        _use(SuccessContract.successFunction.selector, _successContract);

        // Currently we cannot use expectCall for detecting delegatecall
        // https://github.com/foundry-rs/forge-std/issues/574
        // vm.expectCall(target, abi.encodeCall(SuccessContract.successFunction, 1), 2);
        vm.expectCall(target, abi.encodeCall(SuccessContract.successFunction, 0), 2);

        vm.expectEmit(true, true, false, true);
        emit TextDAOEvents.ProposalExecuted(0, 1);

        Execute(target).execute(0);

        assertTrue($proposal.meta.fullyExecuted, "FullyExecuted Flag should be true");
        assertTrue($proposal.meta.actionStatuses[0] == Schema.ActionStatus.Executed);
        assertTrue($proposal.meta.actionStatuses[1] == Schema.ActionStatus.Executed);
    }

    function test_execute_partial_success() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAction("successFunction(uint256)", abi.encode(uint(0)));
        $cmd.createAction("successFunction(uint256)", abi.encode(uint(0)));
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Executed;
        $proposal.meta.actionStatuses[1] = Schema.ActionStatus.Approved;

        address _successContract = address(new SuccessContract());
        _use(SuccessContract.successFunction.selector, _successContract);

        vm.expectCall(target, abi.encodeCall(SuccessContract.successFunction, 0), 1);

        vm.expectEmit(true, true, false, true);
        emit TextDAOEvents.ProposalExecuted(0, 1);

        Execute(target).execute(0);

        assertTrue($proposal.meta.fullyExecuted);
        assertTrue($proposal.meta.actionStatuses[0] == Schema.ActionStatus.Executed);
        assertTrue($proposal.meta.actionStatuses[1] == Schema.ActionStatus.Executed);
    }

    function test_execute_revert_beforeApproved() public {
        Storage.Deliberation().createProposal();

        vm.expectRevert(TextDAOErrors.ProposalNotApproved.selector);
        Execute(target).execute(0);
    }

    function test_execute_revert_alreadyFullyExecuted() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        $proposal.meta.fullyExecuted = true;

        vm.expectRevert(TextDAOErrors.ProposalAlreadyFullyExecuted.selector);
        Execute(target).execute(0);
    }

    function test_execute_revert_actionExecutionFailed() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAction("revertingFunction()", "");
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        _use(bytes4(keccak256("revertingFunction()")), address(new RevertingContract()));

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.ActionExecutionFailed.selector, 0));
        Execute(target).execute(0);
    }
}

contract RevertingContract {
    function revertingFunction() external pure {
        revert("Action execution failed");
    }
}

contract SuccessContract is ProtectionBase {
    function successFunction(uint pid) external protected(pid) returns(bool) {
        return true;
    }
}
