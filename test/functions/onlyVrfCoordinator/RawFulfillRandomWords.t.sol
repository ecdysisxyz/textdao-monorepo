// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

import {
    RawFulfillRandomWords,
    Storage,
    Schema,
    OnlyVrfCoordinatorBase
} from "bundle/textDAO/functions/onlyVrfCoordinator/RawFulfillRandomWords.sol";

contract RawFulfillRandomWordsTest is MCTest {

    function setUp() public {
        _use(RawFulfillRandomWords.rawFulfillRandomWords.selector, address(new RawFulfillRandomWords()));
    }

    function test_rawFulfillRandomWords_success(Schema.Member[] calldata members, uint256 proposalId, uint256 requestId, uint256[] calldata randomWords) public {
        vm.assume(members.length > 0);

        Storage.$VRF().requests[requestId].proposalId = proposalId;

        Schema.MemberJoinProtectedStorage storage $member = Storage.$Members();
        for (uint i; i < members.length; ++i) {
            $member.members[i] = members[i];
        }
        $member.nextMemberId = members.length;

        Schema.ProposalMeta storage $proposalMeta = Storage.$Proposals().proposals[proposalId].proposalMeta;
        assertEq($proposalMeta.reps.length, 0);

        TestUtils.setMsgSenderAsVrfCoordinator();
        // TODO Gas metering
        RawFulfillRandomWords(target).rawFulfillRandomWords(requestId, randomWords);

        assertEq($proposalMeta.reps.length, randomWords.length);
    }

    function test_rawFulfillRandomWords_revert_notVrfCoordinator() public {
        vm.expectRevert(OnlyVrfCoordinatorBase.YouAreNotTheVrfCoordinator.selector);
        RawFulfillRandomWords(target).rawFulfillRandomWords(0, new uint256[](1));
    }

}
