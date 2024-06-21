// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {SelectorLib} from "bundle/textDAO/functions/_utils/SelectorLib.sol";
// Interface
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

abstract contract ProtectionBase {
    /**
    * 1. MUST Approved
    * 2. MUST NOT Executed yet
    */
    modifier protected(uint pid) {
        // TODO ProposalNotFound
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals[pid];
        Schema.ProposalMeta storage $proposalMeta = $proposal.proposalMeta;
        Schema.DeliberationConfig storage $config = Storage.Deliberation().config;
        // if (block.timestamp <= $proposalMeta.createdAt + $config.expiryDuration) revert TextDAOErrors.ProposalNotExpiredYet();
        // if ($proposal.cmdRank.length == 0) revert TextDAOErrors.ProposalNotTalliedYet();
        Schema.Action[] storage actions = $proposal.cmds[$proposalMeta.cmdRank[0]].actions;
        bool approved;
        for (uint i; i < actions.length; ++i) {
            Schema.ActionStatus actionStatus = $proposal.cmds[$proposalMeta.cmdRank[0]].actionStatuses[i];
            if (
                keccak256(bytes.concat(SelectorLib.selector(actions[i].funcSig), actions[i].abiParams)) ==
                keccak256(msg.data)
            ) {
                if (actionStatus == Schema.ActionStatus.Executed) {
                    revert TextDAOErrors.ActionAlreadyExecuted();
                }
                if (actionStatus == Schema.ActionStatus.Approved) {
                    approved = true;
                }
            }
        }
        if (!approved) revert TextDAOErrors.ActionNotApprovedYet();
        _;
    }
}
