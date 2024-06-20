// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

import {
    RawFulfillRandomWords,
    Storage,
    Schema
} from "bundle/textDAO/functions/onlyVrfCoordinator/RawFulfillRandomWords.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

contract RawFulfillRandomWordsTest is MCTest {

    function setUp() public {
        _use(RawFulfillRandomWords.rawFulfillRandomWords.selector, address(new RawFulfillRandomWords()));
    }

    function test_rawFulfillRandomWords_success(Schema.Member[] calldata members, uint256 requestId, uint256[] calldata randomWords) public {
        vm.assume(members.length > 0);

        // proposalId = 0
        Storage.$VRF().requests[requestId].proposalId = 0;

        Schema.Member[] storage $members = Storage.Members().members;
        for (uint i; i < members.length; ++i) {
            $members.push(members[i]);
        }

        Schema.ProposalMeta storage $proposalMeta = Storage.Deliberation().proposals.push().proposalMeta;
        assertEq($proposalMeta.reps.length, 0);

        TestUtils.setMsgSenderAsVrfCoordinator();
        // TODO Gas metering
        RawFulfillRandomWords(target).rawFulfillRandomWords(requestId, randomWords);

        assertEq($proposalMeta.reps.length, randomWords.length);
    }

    function test_rawFulfillRandomWords_revert_notVrfCoordinator() public {
        vm.expectRevert(TextDAOErrors.YouAreNotTheVrfCoordinator.selector);
        RawFulfillRandomWords(target).rawFulfillRandomWords(0, new uint256[](1));
    }

}
