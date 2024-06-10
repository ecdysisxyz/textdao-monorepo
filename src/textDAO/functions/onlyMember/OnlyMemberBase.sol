// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { console2 } from "forge-std/console2.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

abstract contract OnlyMemberBase {
    modifier onlyMember() {
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();

        bool result;

        for (uint i; i < $member.nextMemberId; i++) {
            result = $member.members[i].addr == msg.sender || result;
        }
        require(result, "You are not the member.");
        _;
    }
}
