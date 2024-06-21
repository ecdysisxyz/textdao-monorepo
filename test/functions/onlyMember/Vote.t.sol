// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import {MCTest} from "@devkit/Flattened.sol";
// import {TestUtils} from "test/fixtures/TestUtils.sol";

// import {
//     Vote,
//     Storage,
//     Schema
// } from "bundle/textDAO/functions/onlyReps/Vote.sol";
// import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

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
