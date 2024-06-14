// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

import {
    OnlyVrfCoordinatorBase,
    Storage
} from "bundle/textDAO/functions/onlyVrfCoordinator/OnlyVrfCoordinatorBase.sol";

contract OnlyVrfCoordinator is OnlyVrfCoordinatorBase {
    function doSomething() public onlyVrfCoordinator returns(bool) {
        return true;
    }
}

contract OnlyVrfCoordinatorTest is MCTest {
    function setUp() public {
        _use(OnlyVrfCoordinator.doSomething.selector, address(new OnlyVrfCoordinator()));
    }

    function test_onlyVrfCoordinator_success() public {
        TestUtils.setMsgSenderAsVrfCoordinator();
        assertTrue(OnlyVrfCoordinator(target).doSomething());
    }

    function test_onlyVrfCoordinator_revert_notRep(address vrfCoordinator, address caller) public {
        Storage.$VRF().config.vrfCoordinator = vrfCoordinator;

        vm.assume(vrfCoordinator != caller);
        vm.prank(caller);
        vm.expectRevert(OnlyVrfCoordinatorBase.YouAreNotTheVrfCoordinator.selector);
        OnlyVrfCoordinator(target).doSomething();
    }

}
