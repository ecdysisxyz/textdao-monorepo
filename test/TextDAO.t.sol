// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import { Propose } from "bundle/textDAO/functions/onlyMember/Propose.sol";
import { Fork } from "bundle/textDAO/functions/onlyReps/Fork.sol";
import { Vote } from "bundle/textDAO/functions/onlyMember/Vote.sol";
import { Execute } from "bundle/textDAO/functions/Execute.sol";
import { Tally } from "bundle/textDAO/functions/Tally.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { SaveTextProtected } from "bundle/textDAO/functions/protected/SaveTextProtected.sol";
import { MemberJoinProtected } from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";
import {DeliberationLib} from "bundle/textDAO/storages/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/storages/utils/CommandLib.sol";

contract TextDAOTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Command;

    function setUp() public {
        _use(Propose.propose.selector, address(new Propose()));
        _use(Fork.fork.selector, address(new Fork()));
        _use(Execute.execute.selector, address(new Execute()));
        address vote = address(new Vote());
        _use(Vote.voteHeaders.selector, vote);
        _use(Vote.voteCmds.selector, vote);
        _use(Tally.tally.selector, address(new Tally()));
        _use(SaveTextProtected.saveText.selector, address(new SaveTextProtected()));
        _use(MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
    }

    function test_execute_successWithText() public {
        // Note: Array variable is only available as function args.
        string[] memory metadataURIs = new string[](2);
        metadataURIs[0] = "1";
        metadataURIs[1] = "2";

        Schema.Deliberation storage $Deliberation = Storage.Deliberation();
        Schema.Proposal storage $proposal = $Deliberation.createProposal();

        uint pid = 0;
        uint textId = 0;

        $proposal.cmds.push().createSaveTextAction(pid, textId, metadataURIs).status = Schema.ActionStatus.Approved; // Note: initialize for storage array
        $proposal.proposalMeta.cmdRank = [uint256(1), 0, 0]; // Note: initialize for storage array

        // assertEq($text.metadataURIs.length, 0);
        Execute(address(this)).execute(pid);

        Schema.Text storage $text = Storage.Texts().texts[textId];
        assertGt($text.metadataURIs.length, 0);
    }



    function test_execute_successWithJoin() public {
        Schema.Member[] memory candidates = new Schema.Member[](2);
        Schema.Member memory member1;
        member1.addr = address(1);
        candidates[0] = member1;
        Schema.Member memory member2;
        member2.addr = address(2);
        candidates[1] = member2;

        Schema.Deliberation storage $Deliberation = Storage.Deliberation();
        Schema.Proposal storage $proposal = $Deliberation.createProposal();

        uint pid = 0;

        Schema.Members storage $m = Storage.Members();

        $proposal.cmds.push().createMemberJoinAction(pid, candidates).status = Schema.ActionStatus.Approved; // Note: initialize for storage array

        $proposal.proposalMeta.cmdRank = [uint256(1), 0, 0]; // Note: initialize for storage array

        // assertEq($m.members[0].addr, address(0));
        // assertEq($m.members[1].addr, address(0));
        assertEq($m.members.length, 0);
        Execute(address(this)).execute(pid);
        assertEq($m.members[0].addr, address(1));
        assertEq($m.members[1].addr, address(2));
        assertEq($m.members.length, candidates.length);
    }

}
