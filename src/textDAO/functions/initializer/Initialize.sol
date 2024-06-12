// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";

contract Initialize is Initializable {
    function initialize(address[] calldata initialMembers, Schema.ProposalsConfig calldata pConfig) external initializer {
        // 1. Set Members
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();
        uint nextMemberId;
        for (uint i; i < initialMembers.length; ++i) {
            $member.members[i].id = i;
            $member.members[i].addr = initialMembers[i];
            nextMemberId++;
        }
        $member.nextMemberId = nextMemberId;

        // 2. Set ProposalsConfig
        Schema.ProposalsConfig storage $pConfig = Storage.$Proposals().config;
        $pConfig.expiryDuration = pConfig.expiryDuration;
        $pConfig.tallyInterval = pConfig.tallyInterval;
        $pConfig.repsNum = pConfig.repsNum;
        $pConfig.quorumScore = pConfig.quorumScore;

        /// @dev emit Initialized(1) @Initializable.initializer()

    }
}
