// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

/**
 * @title DeliberationLib v0.1.0
 */
library DeliberationLib {
    function createProposal(Schema.Deliberation storage deliberation) internal returns(Schema.Proposal storage proposal) {
        proposal = deliberation.proposals.push();

        /// Note Avoid using index 0 of the array as it is reserved for the initial value.
        proposal.headers.push();
        proposal.cmds.push();

        proposal.proposalMeta.createdAt = block.timestamp;
        proposal.proposalMeta.expirationTime = block.timestamp + Storage.Deliberation().config.expiryDuration;
        // TODO Add Expiration Time
    }
}
