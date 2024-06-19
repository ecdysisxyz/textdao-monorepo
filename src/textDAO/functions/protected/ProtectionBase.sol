// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

contract ProtectionBase {
    /**
    * 1. MUST Approved (MUST NOT Executed yet)
    */
    modifier protected(uint pid) {
        // TODO ProposalNotFound
        Schema.ProposalMeta storage $proposal = Storage.DAOState().proposals[pid].proposalMeta;
        Schema.DeliberationConfig storage $config = Storage.DAOState().config;
        if (block.timestamp <= $proposal.createdAt + $config.expiryDuration) revert TextDAOErrors.ProposalNotExpiredYet();
        if ($proposal.cmdRank.length == 0) revert TextDAOErrors.ProposalNotTalliedYet();
        _;
    }
}
