// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {MemberLib} from "bundle/textdao/utils/MemberLib.sol";
// Interface
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";

abstract contract OnlyMemberBase {
    using MemberLib for Schema.Members;

    modifier onlyMember() {
        if (!Storage.Members().isMember(msg.sender)) {
            revert TextDAOErrors.YouAreNotTheMember();
        }

        _;
    }
}


// Testing
import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

contract OnlyMemberTester is OnlyMemberBase {
    function doSomething() public onlyMember returns(bool) {
        return true;
    }
}

contract OnlyMemberTest is MCTest {
    function setUp() public {
        _use(OnlyMemberTester.doSomething.selector, address(new OnlyMemberTester()));
    }

    function test_onlyMember_success() public {
        TestUtils.setMsgSenderAsMember();
        assertTrue(OnlyMemberTester(target).doSomething());
    }

    function test_onlyMember_success(Schema.Member[] memory members, uint membersIndex) public {
        Schema.Member[] storage $members = Storage.Members().members;
        for (uint i; i < members.length; ++i) {
            $members.push(members[i]);
        }

        vm.assume(membersIndex < members.length);
        vm.prank(members[membersIndex].addr);
        assertTrue(OnlyMemberTester(target).doSomething());
    }

    function test_onlyMember_revert_notMember(address caller) public {
        vm.prank(caller);
        vm.expectRevert(TextDAOErrors.YouAreNotTheMember.selector);
        OnlyMemberTester(target).doSomething();
    }

}
