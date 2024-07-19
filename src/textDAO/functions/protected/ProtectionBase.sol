// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/utils/CommandLib.sol";
// Interface
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

abstract contract ProtectionBase {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Action;

    /**
    * 1. MUST Approved
    * 2. MUST NOT Executed yet
    */
    modifier protected(uint pid) {
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);
        uint _approvedCmdId = $proposal.meta.approvedCommandId;
        Schema.Command storage $command = $proposal.cmds[_approvedCmdId];

        bytes32 currentCallDataHash = keccak256(msg.data);
        uint actionLength = $command.actions.length;

        for (uint i; i < actionLength; ++i) {
            Schema.Action storage $action = $command.actions[i];
            if (keccak256($action.calcCallData()) == currentCallDataHash) {
                Schema.ActionStatus actionStatus = $proposal.meta.actionStatuses[i];
                if (actionStatus == Schema.ActionStatus.Executed) {
                    continue;
                    // revert TextDAOErrors.ActionAlreadyExecuted();
                }
                if (actionStatus != Schema.ActionStatus.Approved) {
                    revert TextDAOErrors.ActionNotApprovedYet();
                }

                _;

                $proposal.meta.actionStatuses[i] = Schema.ActionStatus.Executed;
                return;
            }
        }

        revert TextDAOErrors.ActionNotFound();
    }

}


// Testing
import {MCTest} from "@devkit/Flattened.sol";

contract ProtectionBaseTester is ProtectionBase {
    function doSomething(uint pid) public protected(pid) returns(bool) {
        return true;
    }
}

contract ProtectionBaseTesterTest is MCTest {
    function setUp() public {
        _use(ProtectionBaseTester.doSomething.selector, address(new ProtectionBaseTester()));
    }

    function test_protected_success() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals.push();
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.actions.push(Schema.Action({
            funcSig: "doSomething(uint256)",
            abiParams: abi.encode(0)
        }));
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;
        $proposal.meta.cmdRank = new uint[](3);

        assertTrue(ProtectionBaseTester(target).doSomething(0));
    }

}
