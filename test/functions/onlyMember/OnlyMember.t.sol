// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";

import {
    OnlyMemberBase,
    Storage,
    Schema
} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

contract OnlyMember is OnlyMemberBase {
    function doSomething() public onlyMember returns(bool) {
        return true;
    }
}

contract OnlyMemberTest is MCTest {
    function setUp() public {
        _use(OnlyMember.doSomething.selector, address(new OnlyMember()));
    }

    function test_onlyMember_success() public {
        TestUtils.setMsgSenderAsMember();
        assertTrue(OnlyMember(target).doSomething());
    }

    function test_onlyMember_success(Schema.Member[] memory members, uint membersIndex) public {
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();
        for (uint i; i < members.length; ++i) {
            $member.members[i] = members[i];
        }
        $member.nextMemberId = members.length;
        vm.assume(membersIndex < members.length);
        vm.prank(members[membersIndex].addr);
        assertTrue(OnlyMember(target).doSomething());
    }

    function test_onlyMember_revert_notMember(address caller) public {
        vm.prank(caller);
        vm.expectRevert("You are not the member.");
        OnlyMember(target).doSomething();
    }

}
