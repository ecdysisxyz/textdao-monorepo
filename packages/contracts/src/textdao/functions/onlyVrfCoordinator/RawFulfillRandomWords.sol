// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyVrfCoordinatorBase} from "bundle/textdao/functions/onlyVrfCoordinator/OnlyVrfCoordinatorBase.sol";
// Storage
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
// Interface
import {VRFConsumerV2Interface} from "bundle/textdao/interfaces/VRFConsumerV2Interface.sol";

contract RawFulfillRandomWords is VRFConsumerV2Interface, OnlyVrfCoordinatorBase {
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external onlyVrfCoordinator {
        Storage.$VRF().requests[requestId].randomWords = randomWords;

        uint256 proposalId = Storage.$VRF().requests[requestId].proposalId;
        Schema.ProposalMeta storage $proposalMeta = Storage.Deliberation().proposals[proposalId].meta;
        Schema.Member[] storage $members = Storage.Members().members;

        for (uint i; i < randomWords.length; i++) {
            uint pickedIndex = uint256(randomWords[i]) % $members.length;
            $proposalMeta.reps.push($members[pickedIndex].addr);
        }
    }
}


// Testing
import {MCTest} from "@mc-devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";

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

        Schema.ProposalMeta storage $proposalMeta = Storage.Deliberation().proposals.push().meta;
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
