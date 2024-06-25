// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

interface TextDAOEvents {
    // Propose
    event HeaderProposed(uint pid, string metadataURI);
    event CommandProposed(uint pid, Schema.Action[] actions);
    // Fork
    event HeaderForked(uint pid, string metadataURI);
    event CommandForked(uint pid, Schema.Action[] actions);
    // Vote
    event HeaderScored(uint pid, uint headerId, uint currentScore);
    event CmdScored(uint pid, uint cmdId, uint currentScore);
    // Tally
    event ProposalTalliedWithTie(uint pid, uint[] approvedHeaderIds, uint[] approvedCommandIds);
    event ProposalTallied(uint pid, uint approvedHeaderId, uint approvedCommandId);
    // event ProposalTallied(uint pid, uint approvedHeaderId, uint approvedHeaderScore, uint approvedCommandId, uint approvedCommandScore);
    // SaveText
    event TextSaved(uint pid, Schema.Text text);
    /// @dev From Initializable @ openzeppelin-contracts~5.0.0
    event Initialized(uint64 version);
}
