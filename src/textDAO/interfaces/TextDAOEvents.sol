// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

interface TextDAOEvents {
    // Propose
    event HeaderProposed(uint pid, Schema.Header header);
    event CommandProposed(uint pid, Schema.Command cmd);
    // Vote
    event HeaderScored(uint pid, uint headerId, uint currentScore);
    event CmdScored(uint pid, uint cmdId, uint currentScore);
    // Fork
    event HeaderForked(uint pid, Schema.Header header);
    event CommandForked(uint pid, Schema.Command cmd);
    // Tally
    event ProposalTallied(uint pid, Schema.ProposalMeta proposalMeta);
    // SaveText
    event TextSaved(uint pid, Schema.Text text);
}
