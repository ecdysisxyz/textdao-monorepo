// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VRFConsumerV2Interface} from "bundle/textDAO/interfaces/VRFConsumerV2Interface.sol";
import {OnlyVrfCoordinatorBase} from "bundle/textDAO/functions/onlyVrfCoordinator/OnlyVrfCoordinatorBase.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

contract RawFulfillRandomWords is VRFConsumerV2Interface, OnlyVrfCoordinatorBase {
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external onlyVrfCoordinator {
        uint256 proposalId = Storage.$VRF().requests[requestId].proposalId;
        Schema.Proposal storage $p = Storage.$Proposals().proposals[proposalId];
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();

        for (uint i; i < randomWords.length; i++) {
            uint pickedIndex = uint256(randomWords[i]) % $member.nextMemberId;
            $p.proposalMeta.reps.push($member.members[pickedIndex].addr);
            $p.proposalMeta.nextRepId++;
        }
    }
}
