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

    function test_memberJoin_success(Schema.Member[] memory candidates) public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        $proposal.proposalMeta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createMemberJoinAction(0, candidates);
        $proposal.proposalMeta.actionStatuses[0] = Schema.ActionStatus.Approved;

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
        $proposal.proposalMeta.approvedCommandId = 1;
        $proposal.cmds.push().createMemberJoinAction(0, new Schema.Member[](1));

        vm.expectRevert(TextDAOErrors.ActionNotApprovedYet.selector);
        MemberJoinProtected(target).memberJoin({
            pid: 0,
            candidates: new Schema.Member[](1)
        });
    }

    function test_memberJoin_revert_notFound() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.proposalMeta.approvedCommandId = 1;
        $proposal.cmds.push().createMemberJoinAction(0, new Schema.Member[](1));
        $proposal.proposalMeta.actionStatuses[0] = Schema.ActionStatus.Executed;

        vm.expectRevert(TextDAOErrors.ActionNotFound.selector);
        MemberJoinProtected(target).memberJoin({
            pid: 0,
            candidates: new Schema.Member[](1)
        });
    }

}
