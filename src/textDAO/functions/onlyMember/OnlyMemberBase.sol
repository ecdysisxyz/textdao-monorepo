// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

abstract contract OnlyMemberBase {
    error YouAreNotTheMember();

    modifier onlyMember() {
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();

        bool result;

        for (uint i; i < $member.nextMemberId; i++) {
            result = $member.members[i].addr == msg.sender || result;
        }
        if (!result) revert YouAreNotTheMember();
        _;
    }

}
