// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";
// Interface
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";

abstract contract OnlyRepsBase {
    using DeliberationLib for Schema.Deliberation;

    modifier onlyReps(uint pid) {
        address[] storage $reps = Storage.Deliberation().getProposal(pid).meta.reps;

        bool result;
        for (uint i; i < $reps.length; ++i) {
            if ($reps[i] == msg.sender) {
                result = true;
                break;
            }
        }
        if (!result) revert TextDAOErrors.YouAreNotTheRep();

        _;
    }

}


// Testing
import {MCTest} from "@mc-devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

contract OnlyRepsTester is OnlyRepsBase {
    function doSomething(uint256 pid) public onlyReps(pid) returns(bool) {
        return true;
    }
}

contract OnlyRepsTest is MCTest {
    function setUp() public {
        _use(OnlyRepsTester.doSomething.selector, address(new OnlyRepsTester()));
    }

    function test_onlyReps_success() public {
        Storage.Deliberation().proposals.push();

        TestUtils.setMsgSenderAsRep(0);
        assertTrue(OnlyRepsTester(target).doSomething(0));
    }

    function test_onlyReps_success(address[] calldata reps, uint256 repIndex) public {
        // proposalId = 0
        Storage.Deliberation().proposals.push().meta.reps = reps;

        vm.assume(repIndex < reps.length);
        vm.prank(reps[repIndex]);
        assertTrue(OnlyRepsTester(target).doSomething(0));
    }

    function test_onlyReps_revert_notRep(address[] calldata reps, uint256 repIndex, address caller) public {
        // proposalId = 0
        Storage.Deliberation().proposals.push().meta.reps = reps;

        vm.assume(repIndex < reps.length);
        for (uint i; i < reps.length; ++i) {
            vm.assume(reps[i] != caller);
        }
        vm.prank(caller);
        vm.expectRevert(TextDAOErrors.YouAreNotTheRep.selector);
        OnlyRepsTester(target).doSomething(0);
    }

}
