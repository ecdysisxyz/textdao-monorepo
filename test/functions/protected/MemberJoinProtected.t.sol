// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";

import {
    MemberJoinProtected,
    Storage,
    Schema
} from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

import {DeliberationLib} from "bundle/textDAO/storages/utils/DeliberationLib.sol";
using DeliberationLib for Schema.Deliberation;
import {CommandLib} from "bundle/textDAO/storages/utils/CommandLib.sol";
using CommandLib for Schema.Command;

contract MemberJoinProtectedTest is MCTest {

    function setUp() public {
        _use(MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
    }

    function test_memberJoin_success(uint256 proposeTime, uint256 expiryTime, uint256 execTime, Schema.Member[] memory candidates) public {
        vm.warp(proposeTime);
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        // Storage.Deliberation().proposals.push().proposalMeta.createdAt = proposeTime;
        vm.assume(expiryTime >= proposeTime);
        Storage.Deliberation().config.expiryDuration = expiryTime - proposeTime;
        vm.assume(expiryTime < execTime);
        vm.warp(execTime);

        $proposal.proposalMeta.cmdRank = [uint256(1), 0, 0];
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createMemberJoinAction(0, candidates);
        $cmd.actionStatuses[0] = Schema.ActionStatus.Approved;

        MemberJoinProtected(target).memberJoin({
            pid: 0,
            candidates: candidates
        });

        for (uint i; i < candidates.length; ++i) {
            assertEq(
                keccak256(abi.encode(candidates[i])),
                keccak256(abi.encode(Storage.Members().members[i]))
            );
        }
        assertEq(candidates.length, Storage.Members().members.length);
    }

    function test_memberJoin_revert_notApprovedYet() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.proposalMeta.cmdRank = [uint256(1), 0, 0];
        $proposal.cmds.push().createMemberJoinAction(0, new Schema.Member[](1));

        vm.expectRevert(TextDAOErrors.ActionNotApprovedYet.selector);
        MemberJoinProtected(target).memberJoin({
            pid: 0,
            candidates: new Schema.Member[](1)
        });
    }

    function test_memberJoin_revert_alreadyExecuted() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.proposalMeta.cmdRank = [uint256(1), 0, 0];
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createMemberJoinAction(0, new Schema.Member[](1));
        $cmd.actionStatuses[0] = Schema.ActionStatus.Executed;

        vm.expectRevert(TextDAOErrors.ActionAlreadyExecuted.selector);
        MemberJoinProtected(target).memberJoin({
            pid: 0,
            candidates: new Schema.Member[](1)
        });
    }

}
