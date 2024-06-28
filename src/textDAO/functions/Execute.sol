// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/storages/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/storages/utils/CommandLib.sol";
import {IExecute} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

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
