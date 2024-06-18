// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

import {
    OnlyRepsBase,
    Storage,
    Schema
} from "bundle/textDAO/functions/onlyReps/OnlyRepsBase.sol";

contract OnlyReps is OnlyRepsBase {
    function doSomething(uint256 pid) public onlyReps(pid) returns(bool) {
        return true;
    }
}

contract OnlyRepsTest is MCTest {
    function setUp() public {
        _use(OnlyReps.doSomething.selector, address(new OnlyReps()));
    }

    function test_onlyReps_success() public {
        TestUtils.setMsgSenderAsRep(0);
        assertTrue(OnlyReps(target).doSomething(0));
    }

    function test_onlyReps_success(address[] calldata reps, uint256 repIndex, uint256 pid) public {
        Storage.DAOState().proposals[pid].proposalMeta.reps = reps;

        vm.assume(repIndex < reps.length);
        vm.prank(reps[repIndex]);
        assertTrue(OnlyReps(target).doSomething(pid));
    }

    function test_onlyReps_revert_notRep(address[] calldata reps, uint256 repIndex, uint256 pid, address caller) public {
        Storage.DAOState().proposals[pid].proposalMeta.reps = reps;

        vm.assume(repIndex < reps.length);
        for (uint i; i < reps.length; ++i) {
            vm.assume(reps[i] != caller);
        }
        vm.prank(caller);
        vm.expectRevert(OnlyRepsBase.YouAreNotTheRep.selector);
        OnlyReps(target).doSomething(pid);
    }

}
