// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

import {
    Fork,
    IFork,
    Storage,
    Schema
} from "bundle/textDAO/functions/onlyReps/Fork.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

contract ForkTest is MCTest {

    function setUp() public {
        _use(Fork.fork.selector, address(new Fork()));
    }

    function test_fork_success() public {
        uint pid = 0;
        Schema.Proposal storage $p = Storage.Deliberation().proposals.push();

        assertEq($p.headers.length, 0);
        assertEq($p.cmds.length, 0);

        TestUtils.setMsgSenderAsRep(pid);
        Fork(target).fork({
            pid: pid,
            headerMetadataURI: "Qc.....xh",
            actions: new Schema.Action[](1)
        });

        assertEq($p.headers.length, 1);
        assertEq($p.cmds.length, 1);
    }

    function test_fork_revert_notRep() public {
        Storage.Deliberation().proposals.push();

        vm.expectRevert(TextDAOErrors.YouAreNotTheRep.selector);
        Fork(target).fork({
            pid: 0,
            headerMetadataURI: "Qc.....xh",
            actions: new Schema.Action[](1)
        });
    }

}
