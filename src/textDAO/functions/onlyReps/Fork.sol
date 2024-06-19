// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OnlyRepsBase} from "bundle/textDAO/functions/onlyReps/OnlyRepsBase.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {Types} from "bundle/textDAO/storages/Types.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

contract Fork is OnlyRepsBase {
    function fork(uint pid, Types.ProposalArg calldata _p) external onlyReps(pid) {
        Schema.Proposal storage $p = Storage.DAOState().proposals[pid];

        if (_p.header.metadataURI.length > 0) {
            $p.headers.push(_p.header);
            emit TextDAOEvents.HeaderForked(pid, _p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $p.cmds.push(_p.cmd);
            emit TextDAOEvents.CommandForked(pid, _p.cmd);
        }
        // Note: Shadow(sender, timestamp)
    }
}
