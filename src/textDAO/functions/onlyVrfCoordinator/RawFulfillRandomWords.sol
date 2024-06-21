// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyVrfCoordinatorBase} from "bundle/textDAO/functions/onlyVrfCoordinator/OnlyVrfCoordinatorBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
// Interface
import {VRFConsumerV2Interface} from "bundle/textDAO/interfaces/VRFConsumerV2Interface.sol";

contract RawFulfillRandomWords is VRFConsumerV2Interface, OnlyVrfCoordinatorBase {
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external onlyVrfCoordinator {
        Storage.$VRF().requests[requestId].randomWords = randomWords;

        uint256 proposalId = Storage.$VRF().requests[requestId].proposalId;
        Schema.Proposal storage $p = Storage.Deliberation().proposals[proposalId];
        Schema.Member[] storage $members = Storage.Members().members;

        for (uint i; i < randomWords.length; i++) {
            uint pickedIndex = uint256(randomWords[i]) % $members.length;
            $p.proposalMeta.reps.push($members[pickedIndex].addr);
        }
    }
}
