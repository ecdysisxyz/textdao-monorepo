// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";

contract Initialize is Initializable {
    function initialize(address[] calldata initialMembers, Schema.ProposalsConfig calldata pConfig) external initializer returns (bool) {

        Schema.MemberJoinProtectedStorage storage $ = Storage.$Members();
        Schema.ProposalsConfig storage $pConfig = Storage.$Proposals().config;
        $pConfig.expiryDuration = pConfig.expiryDuration;
        $pConfig.tallyInterval = pConfig.tallyInterval;
        $pConfig.repsNum = pConfig.repsNum;
        $pConfig.quorumScore = pConfig.quorumScore;

        uint currentMemberId = $.nextMemberId;
        for (uint i = 0; i < initialMembers.length; i++) {
            $.members[currentMemberId].id = currentMemberId;
            $.members[currentMemberId].addr = initialMembers[i];
            $.members[currentMemberId].metadataURI = "";
            currentMemberId++;
        }
        $.nextMemberId = currentMemberId;
        return true;
    }
}
