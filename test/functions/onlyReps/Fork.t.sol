// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

import {
    Fork,
    Storage,
    Schema,
    Types,
    OnlyRepsBase
} from "bundle/textDAO/functions/onlyReps/Fork.sol";

contract ForkTest is MCTest {

    function setUp() public {
        _use(Fork.fork.selector, address(new Fork()));
    }

    function test_fork_success() public {
        uint pid = 0;
        Schema.Proposal storage $p = Storage.DAOState().proposals.push();

        Types.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";
        p.cmd.actions = new Schema.Action[](1);

        assertEq($p.headers.length, 0);
        assertEq($p.cmds.length, 0);

        TestUtils.setMsgSenderAsRep(pid);
        Fork(address(this)).fork(pid, p);

        assertEq($p.headers.length, 1);
        assertEq($p.cmds.length, 1);
    }

    function test_fork_revert_notRep() public {
        Storage.DAOState().proposals.push();

        Types.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";
        p.cmd.actions = new Schema.Action[](1);

        vm.expectRevert(OnlyRepsBase.YouAreNotTheRep.selector);
        Fork(address(this)).fork(0, p);
    }

}
