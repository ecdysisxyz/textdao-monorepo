// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, VmSafe, console2} from "@devkit/Flattened.sol";

import {Execute} from "bundle/textDAO/functions/Execute.sol";

import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/utils/CommandLib.sol";
// Interface
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

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
