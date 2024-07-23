// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
// Interface
import {IMemberJoin} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";

contract MemberJoinProtected is IMemberJoin, ProtectionBase {
    function memberJoin(uint pid, Schema.Member[] memory candidates) external protected(pid) {
        Schema.Members storage $ = Storage.Members();

        for (uint i; i < candidates.length; ++i) {
            $.members.push(candidates[i]);
        }
    }
}


// Testing
import {MCTest} from "@devkit/Flattened.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/utils/CommandLib.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

contract MemberJoinProtectedTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Command;

    function setUp() public {
        _use(MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
    }

    function test_memberJoin_success(Schema.Member[] memory candidates) public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createMemberJoinAction(0, candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

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
        $proposal.meta.approvedCommandId = 1;
        $proposal.cmds.push().createMemberJoinAction(0, new Schema.Member[](1));

        vm.expectRevert(TextDAOErrors.ActionNotApprovedYet.selector);
        MemberJoinProtected(target).memberJoin({
            pid: 0,
            candidates: new Schema.Member[](1)
        });
    }

    function test_memberJoin_revert_notFound() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        $proposal.cmds.push().createMemberJoinAction(0, new Schema.Member[](1));
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Executed;

        vm.expectRevert(TextDAOErrors.ActionNotFound.selector);
        MemberJoinProtected(target).memberJoin({
            pid: 0,
            candidates: new Schema.Member[](1)
        });
    }

}
