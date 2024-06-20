// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OnlyMemberBase} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

contract Vote is OnlyMemberBase {
    function voteHeaders(uint pid, uint[3] calldata headerIds) external onlyMember returns (bool) {
        // TODO ProposalNotFound
        Schema.Proposal storage $p = Storage.Deliberation().proposals[pid];

        require($p.headers.length > 0, "No headers for this proposal.");

        if ($p.headers[0].id == headerIds[0]) {
            $p.headers[headerIds[0]].currentScore += 3;
            emit TextDAOEvents.HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
        } else if ($p.headers[1].id == headerIds[0]) {
            $p.headers[headerIds[0]].currentScore += 3;
            $p.headers[headerIds[1]].currentScore += 2;
            emit TextDAOEvents.HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
            emit TextDAOEvents.HeaderScored(pid, headerIds[1], $p.headers[headerIds[1]].currentScore);
        } else {
            $p.headers[headerIds[0]].currentScore += 3;
            $p.headers[headerIds[1]].currentScore += 2;
            $p.headers[headerIds[2]].currentScore += 1;
            emit TextDAOEvents.HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
            emit TextDAOEvents.HeaderScored(pid, headerIds[1], $p.headers[headerIds[1]].currentScore);
            emit TextDAOEvents.HeaderScored(pid, headerIds[2], $p.headers[headerIds[2]].currentScore);
        }
    }

    function voteCmds(uint pid, uint[3] calldata cmdIds) external onlyMember returns (bool) {
        // TODO ProposalNotFound
        Schema.Proposal storage $p = Storage.Deliberation().proposals[pid];

        require($p.cmds.length > 0, "No cmds for this proposal.");

        if ($p.cmds[0].id == cmdIds[0]) {
            $p.cmds[cmdIds[0]].currentScore += 3;
            emit TextDAOEvents.CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
        } else if ($p.cmds[1].id == cmdIds[0]) {
            $p.cmds[cmdIds[0]].currentScore += 3;
            $p.cmds[cmdIds[1]].currentScore += 2;
            emit TextDAOEvents.CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
            emit TextDAOEvents.CmdScored(pid, cmdIds[1], $p.cmds[cmdIds[1]].currentScore);
        } else {
            $p.cmds[cmdIds[0]].currentScore += 3;
            $p.cmds[cmdIds[1]].currentScore += 2;
            $p.cmds[cmdIds[2]].currentScore += 1;
            emit TextDAOEvents.CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
            emit TextDAOEvents.CmdScored(pid, cmdIds[1], $p.cmds[cmdIds[1]].currentScore);
            emit TextDAOEvents.CmdScored(pid, cmdIds[2], $p.cmds[cmdIds[2]].currentScore);
        }
    }

}
