// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

import {
    ProtectionBase,
    Storage,
    Schema
} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

contract Protected is ProtectionBase {
    function doSomething(uint pid) public protected(pid) returns(bool) {
        return true;
    }
}

contract ProtectedTest is MCTest {
    function setUp() public {
        _use(Protected.doSomething.selector, address(new Protected()));
    }

    function test_protected_success() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals.push();
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.actions.push(Schema.Action({
            funcSig: "doSomething(uint256)",
            abiParams: abi.encode(0)
        }));
        $cmd.actionStatuses[0] = Schema.ActionStatus.Approved;
        $proposal.proposalMeta.cmdRank = new uint[](3);

        assertTrue(Protected(target).doSomething(0));
    }

}
