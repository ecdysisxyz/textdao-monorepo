// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";

import {Tally} from "bundle/textDAO/functions/Tally.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/storages/utils/DeliberationLib.sol";
// Interface
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

contract TallyTest is MCTest {
    using DeliberationLib for Schema.Deliberation;

    function setUp() public {
        _use(Tally.tally.selector, address(new Tally()));
    }

    function test_tally_success() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        Schema.ProposalMeta storage $proposalMeta = $proposal.proposalMeta;

        Schema.Header[] storage $headers = $proposal.headers;
        Schema.Command[] storage $cmds = $proposal.cmds;

        for (uint i; i < 10; i++) {
            $headers.push();
            $cmds.push();
        }
        $proposalMeta.reps.push(address(1));
        $proposalMeta.votes[address(1)].rankedHeaderIds = [1, 2, 3];
        $proposalMeta.votes[address(1)].rankedCommandIds = [3, 2, 1];
        $proposalMeta.reps.push(address(2));
        $proposalMeta.votes[address(2)].rankedHeaderIds = [3, 2, 4];
        $proposalMeta.votes[address(2)].rankedCommandIds = [3, 2, 1];

        $proposalMeta.expirationTime = block.timestamp - 1;

        Tally(target).tally(0);

        assertEq($proposalMeta.approvedHeaderId, 2);
        assertEq($proposalMeta.approvedCommandId, 3);
    }

    // function test_tally_failCommandQuorumWithOverride() public {
    //     Schema.Deliberation storage $ = Storage.Deliberation();
    //     Schema.Proposal storage $p = $.proposals.push();
    //     Schema.ConfigOverrideStorage storage $configOverride = Storage.$ConfigOverride();

    //     $p.proposalMeta.createdAt = 0;
    //     $.config.expiryDuration = 1000;
    //     $.config.tallyInterval = 1000;

    //     Schema.Header[] storage $headers = $p.headers;
    //     Schema.Command[] storage $cmds = $p.cmds;

    //     for (uint i; i < 10; i++) {
    //         $headers.push();
    //         $cmds.push();
    //         $cmds[i].actions.push();
    //         Schema.Action storage $action = $cmds[i].actions[0];
    //         $action.funcSig = "tally(uint256)";
    //     }
    //     $cmds.push();

    //     $.config.quorumScore = 8;
    //     $configOverride.overrides[Tally.tally.selector].quorumScore = 15;

    //     $p.headers[8].currentScore = 10;
    //     $p.headers[9].currentScore = 9;
    //     $p.headers[3].currentScore = 8;
    //     $p.cmds[4].currentScore = 10;
    //     $p.cmds[5].currentScore = 9;
    //     $p.cmds[6].currentScore = 8;

    //     Tally(target).tally(0);

    //     assertEq($p.proposalMeta.headerRank[0], 8);
    //     assertEq($p.proposalMeta.headerRank[1], 9);
    //     assertEq($p.proposalMeta.headerRank[2], 3);
    //     assertEq($p.proposalMeta.nextHeaderTallyFrom, 10);
    //     assertEq($p.proposalMeta.cmdRank[0], 0);
    //     assertEq($p.proposalMeta.cmdRank[1], 0);
    //     assertEq($p.proposalMeta.cmdRank[2], 0);
    //     assertEq($p.proposalMeta.nextCmdTallyFrom, 0);
    // }

    function test_tally_revert_notExpiredYet(uint256 tallyTime, uint256 expirationTime) public {
        vm.assume(tallyTime <= expirationTime);
        Storage.Deliberation().createProposal().proposalMeta.expirationTime = expirationTime;

        vm.warp(tallyTime);
        vm.expectRevert(TextDAOErrors.ProposalNotExpiredYet.selector);
        Tally(target).tally(0);
    }

}
