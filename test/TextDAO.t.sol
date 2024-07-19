// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {Propose} from "bundle/textDAO/functions/onlyMember/Propose.sol";
import {Fork} from "bundle/textDAO/functions/onlyReps/Fork.sol";
import {Vote} from "bundle/textDAO/functions/onlyReps/Vote.sol";
import {Execute} from "bundle/textDAO/functions/Execute.sol";
import {Tally} from "bundle/textDAO/functions/Tally.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {SaveTextProtected} from "bundle/textDAO/functions/protected/SaveTextProtected.sol";
import {MemberJoinProtected} from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/utils/CommandLib.sol";

contract TextDAOTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Command;

    function setUp() public {
        _use(Propose.propose.selector, address(new Propose()));
        _use(Fork.fork.selector, address(new Fork()));
        _use(Execute.execute.selector, address(new Execute()));
        address vote = address(new Vote());
        _use(Tally.tally.selector, address(new Tally()));
        _use(SaveTextProtected.saveText.selector, address(new SaveTextProtected()));
        _use(MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
    }

    function test_execute_successWithText() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        uint pid = 0;
        uint textId = 0;

        // Note: Array variable is only available as function args.
        string[] memory metadataURIs = new string[](2);
        metadataURIs[0] = "1";
        metadataURIs[1] = "2";

        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createSaveTextAction(pid, textId, metadataURIs);

        uint _actionId = 0;
        uint _approvedCommandId = 1;

        $proposal.meta.actionStatuses[_actionId] = Schema.ActionStatus.Approved;
        $proposal.meta.approvedCommandId = _approvedCommandId;

        Schema.Text[] storage $texts = Storage.Texts().texts;

        assertEq($texts.length, 0);

        Execute(target).execute(pid);

        assertEq($texts.length, 1);
    }



    function test_execute_successWithJoin() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        uint pid = 0;

        Schema.Member[] memory candidates = new Schema.Member[](2);
        candidates[0].addr = address(1);
        candidates[1].addr = address(2);

        $proposal.cmds.push().createMemberJoinAction(pid, candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;
        $proposal.meta.approvedCommandId = 1;

        Schema.Members storage $m = Storage.Members();

        assertEq($m.members.length, 0);

        Execute(target).execute(pid);

        assertEq($m.members.length, candidates.length);
        assertEq($m.members[0].addr, address(1));
        assertEq($m.members[1].addr, address(2));
    }

}
