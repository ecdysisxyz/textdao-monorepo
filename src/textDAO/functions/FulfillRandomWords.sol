// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { console2 } from "forge-std/console2.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract FulfillRandomWords {

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWordsReturned) public returns (bool) {
        Schema.VRFStorage storage $vrf = Storage.$VRF();
        Schema.Request storage $r = $vrf.requests[requestId];
        Schema.ProposeStorage storage $prop = Storage.$Proposals();
        Schema.Proposal storage $p = $prop.proposals[$r.proposalId];
        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();


        uint256[] memory randomWords = randomWordsReturned;

        for (uint i; i < randomWords.length; i++) {
            uint pickedIndex = uint256(randomWords[i]) % $member.nextMemberId;
            $p.proposalMeta.reps[$p.proposalMeta.nextRepId] = $member.members[pickedIndex].addr;
            $p.proposalMeta.nextRepId++;
        }
    }

}
