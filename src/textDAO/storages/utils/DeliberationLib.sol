// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

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
    }

    function getProposal(Schema.Deliberation storage $deliberation, uint pid) internal view returns(Schema.Proposal storage) {
        if ($deliberation.proposals.length <= pid) revert TextDAOErrors.ProposalNotFound();
        return $deliberation.proposals[pid];
    }
}
