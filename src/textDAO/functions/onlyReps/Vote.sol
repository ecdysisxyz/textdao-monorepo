// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyRepsBase} from "bundle/textDAO/functions/onlyReps/OnlyRepsBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
// Interface
import {IVote} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

contract Vote is IVote, OnlyRepsBase {
    function vote(uint pid, Schema.Vote calldata repVote) external onlyReps(pid) {
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals[pid];

        // TODO validate not expired
        // TODO validate correct headerId & commandId

        $proposal.meta.votes[msg.sender] = repVote;
    }

    function voteHeaders(uint pid, uint[3] calldata headerIds) external onlyReps(pid) {
        // TODO ProposalNotFound
        Schema.Proposal storage $p = Storage.Deliberation().proposals[pid];

        require($p.headers.length > 0, "No headers for this proposal.");

        // if ($p.headers[0].id == headerIds[0]) {
        //     $p.headers[headerIds[0]].currentScore += 3;
        //     emit TextDAOEvents.HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
        // } else if ($p.headers[1].id == headerIds[0]) {
        //     $p.headers[headerIds[0]].currentScore += 3;
        //     $p.headers[headerIds[1]].currentScore += 2;
        //     emit TextDAOEvents.HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
        //     emit TextDAOEvents.HeaderScored(pid, headerIds[1], $p.headers[headerIds[1]].currentScore);
        // } else {
        //     $p.headers[headerIds[0]].currentScore += 3;
        //     $p.headers[headerIds[1]].currentScore += 2;
        //     $p.headers[headerIds[2]].currentScore += 1;
        //     emit TextDAOEvents.HeaderScored(pid, headerIds[0], $p.headers[headerIds[0]].currentScore);
        //     emit TextDAOEvents.HeaderScored(pid, headerIds[1], $p.headers[headerIds[1]].currentScore);
        //     emit TextDAOEvents.HeaderScored(pid, headerIds[2], $p.headers[headerIds[2]].currentScore);
        // }
    }

    function voteCmds(uint pid, uint[3] calldata cmdIds) external onlyReps(pid) {
        // TODO ProposalNotFound
        Schema.Proposal storage $p = Storage.Deliberation().proposals[pid];

        require($p.cmds.length > 0, "No cmds for this proposal.");

        // if ($p.cmds[0].id == cmdIds[0]) {
        //     $p.cmds[cmdIds[0]].currentScore += 3;
        //     emit TextDAOEvents.CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
        // } else if ($p.cmds[1].id == cmdIds[0]) {
        //     $p.cmds[cmdIds[0]].currentScore += 3;
        //     $p.cmds[cmdIds[1]].currentScore += 2;
        //     emit TextDAOEvents.CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
        //     emit TextDAOEvents.CmdScored(pid, cmdIds[1], $p.cmds[cmdIds[1]].currentScore);
        // } else {
        //     $p.cmds[cmdIds[0]].currentScore += 3;
        //     $p.cmds[cmdIds[1]].currentScore += 2;
        //     $p.cmds[cmdIds[2]].currentScore += 1;
        //     emit TextDAOEvents.CmdScored(pid, cmdIds[0], $p.cmds[cmdIds[0]].currentScore);
        //     emit TextDAOEvents.CmdScored(pid, cmdIds[1], $p.cmds[cmdIds[1]].currentScore);
        //     emit TextDAOEvents.CmdScored(pid, cmdIds[2], $p.cmds[cmdIds[2]].currentScore);
        // }
    }

}


// Testing
import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

// contract VoteTest is MCTest {
//     function setUp() public {
//         address vote = address(new Vote());
//         _use(Vote.voteHeaders.selector, vote);
//         _use(Vote.voteCmds.selector, vote);
//     }

//     function test_voteHeaders() public {
//         uint fork1stId = 9;
//         uint fork2ndId = 1;
//         uint fork3rdId = 5;
//         Schema.Header[] storage $headers = Storage.Deliberation().proposals.push().headers;
//         for (uint i; i < 10; i++) {
//             $headers.push();
//         }

//         uint fork1stScoreBefore = $headers[fork1stId].currentScore;
//         uint fork2ndScoreBefore = $headers[fork2ndId].currentScore;
//         uint fork3rdScoreBefore = $headers[fork3rdId].currentScore;

//         TestUtils.setMsgSenderAsMember();
//         Vote(address(this)).voteHeaders(0, [fork1stId, fork2ndId, fork3rdId]);

//         uint fork1stScoreAfter = $headers[fork1stId].currentScore;
//         uint fork2ndScoreAfter = $headers[fork2ndId].currentScore;
//         uint fork3rdScoreAfter = $headers[fork3rdId].currentScore;

//         // assertEq(fork1stScoreBefore + 3, fork1stScoreAfter);
//         // assertEq(fork2ndScoreBefore + 2, fork2ndScoreAfter);
//         // assertEq(fork3rdScoreBefore + 1, fork3rdScoreAfter);
//     }

//     function test_voteHeaders_revert_notMember() public {
//         vm.expectRevert(TextDAOErrors.YouAreNotTheRep.selector);
//         Vote(address(this)).voteHeaders(0, [uint(0), 1, 2]);
//     }

//     function test_voteCmds() public {
//         uint fork1stId = 7;
//         uint fork2ndId = 6;
//         uint fork3rdId = 5;
//         Schema.Proposal storage $p = Storage.Deliberation().proposals.push();
//         Schema.Command[] storage $cmds = $p.cmds;
//         for (uint i; i < 10; i++) {
//             $cmds.push();
//         }

//         uint fork1stScoreBefore = $p.cmds[fork1stId].currentScore;
//         uint fork2ndScoreBefore = $p.cmds[fork2ndId].currentScore;
//         uint fork3rdScoreBefore = $p.cmds[fork3rdId].currentScore;

//         TestUtils.setMsgSenderAsMember();
//         Vote(address(this)).voteCmds(0, [fork1stId, fork2ndId, fork3rdId]);

//         uint fork1stScoreAfter = $p.cmds[fork1stId].currentScore;
//         uint fork2ndScoreAfter = $p.cmds[fork2ndId].currentScore;
//         uint fork3rdScoreAfter = $p.cmds[fork3rdId].currentScore;

//         // assertEq(fork1stScoreBefore + 3, fork1stScoreAfter);
//         // assertEq(fork2ndScoreBefore + 2, fork2ndScoreAfter);
//         // assertEq(fork3rdScoreBefore + 1, fork3rdScoreAfter);
//     }

//     function test_voteCmds_revert_notMember() public {
//         vm.expectRevert(TextDAOErrors.YouAreNotTheRep.selector);
//         Vote(address(this)).voteCmds(0, [uint(0), 1, 2]);
//     }

// }
