// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/storages/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/storages/utils/CommandLib.sol";
// Interface
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

abstract contract ProtectionBase {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Action;

    /**
    * 1. MUST Approved
    * 2. MUST NOT Executed yet
    */
    modifier protected(uint pid) {
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);
        uint _approvedCmdId = $proposal.proposalMeta.approvedCommandId;
        Schema.Command storage $command = $proposal.cmds[_approvedCmdId];

        bytes32 currentCallDataHash = keccak256(msg.data);
        uint actionLength = $command.actions.length;

        for (uint i; i < actionLength; ++i) {
            Schema.Action storage $action = $command.actions[i];
            if (keccak256($action.calcCallData()) == currentCallDataHash) {
                Schema.ActionStatus actionStatus = $proposal.proposalMeta.actionStatuses[i];
                if (actionStatus == Schema.ActionStatus.Executed) {
                    continue;
                    // revert TextDAOErrors.ActionAlreadyExecuted();
                }
                if (actionStatus != Schema.ActionStatus.Approved) {
                    revert TextDAOErrors.ActionNotApprovedYet();
                }

                _;

                $proposal.proposalMeta.actionStatuses[i] = Schema.ActionStatus.Executed;
                return;
            }
        }

        revert TextDAOErrors.ActionNotFound();
    }

}
