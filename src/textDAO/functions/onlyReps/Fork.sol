// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyRepsBase} from "bundle/textDAO/functions/onlyReps/OnlyRepsBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {ProposalLib} from "bundle/textDAO/storages/utils/ProposalLib.sol";
// Interface
import {IFork} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

/**
 * @title Fork function
 * @custom:version interface:0.1
 */
contract Fork is IFork, OnlyRepsBase {
    using ProposalLib for Schema.Proposal;

    function fork(uint pid, string calldata headerMetadataURI, Schema.Action[] calldata actions) external onlyReps(pid) {
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals[pid];

        if (bytes(headerMetadataURI).length > 0) {
            $proposal.createHeader(headerMetadataURI);
            emit TextDAOEvents.HeaderForked(pid, headerMetadataURI);
        }
        if (actions.length > 0) {
            $proposal.createCommand(actions);
            emit TextDAOEvents.CommandForked(pid, actions);
        }
        // Note: Shadow(sender, timestamp)
    }
}
