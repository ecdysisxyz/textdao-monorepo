// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OnlyRepsBase} from "bundle/textDAO/functions/onlyReps/OnlyRepsBase.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";

contract Fork is OnlyRepsBase {
    function fork(uint pid, Types.ProposalArg calldata _p) external onlyReps(pid) {
        Schema.Proposal storage $p = Storage.DAOState().proposals[pid];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
        }
        // Note: Shadow(sender, timestamp)
    }
}
