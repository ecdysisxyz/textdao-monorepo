// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyRepsBase} from "bundle/textdao/functions/onlyReps/OnlyRepsBase.sol";
// Storage
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
// Interface
import {IVote} from "bundle/textdao/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";
// Libraries
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";
import {ProposalLib} from "bundle/textdao/utils/ProposalLib.sol";
import {RCVLib} from "bundle/textdao/utils/RCVLib.sol";

/**
 * @title Vote Contract
 * @dev Handles voting functionality for TextDAO proposals
 * @notice This contract allows representatives to cast votes on proposals
 */
contract Vote is IVote, OnlyRepsBase {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;
    using RCVLib for uint;

    /**
     * @notice Allow a representative to vote on a proposal
     * @param pid The ID of the proposal
     * @param repVote The vote structure containing the rep's choices
     * @dev This function checks if the caller is a representative, if the proposal has not expired,
     *      and if the voted header and command IDs are valid before recording the vote.
     */
    function vote(uint pid, Schema.Vote calldata repVote) external onlyReps(pid) {
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);

        if ($proposal.isExpired()) revert TextDAOErrors.ProposalAlreadyExpired();

        _validateVote($proposal, repVote);

        $proposal.meta.votes[msg.sender] = repVote;
        emit TextDAOEvents.Voted(pid, msg.sender, repVote);
    }

    /**
     * @dev Validates the vote structure against the proposal
     * @param $proposal The proposal being voted on
     * @param repVote The vote structure to validate
     */
    function _validateVote(Schema.Proposal storage $proposal, Schema.Vote calldata repVote) internal view {
        for (uint256 i; i < 3; ++i) {
            if (repVote.rankedHeaderIds[i] > $proposal.headers.length - 1) {
                revert TextDAOErrors.InvalidHeaderId(repVote.rankedHeaderIds[i]);
            }
            if (repVote.rankedCommandIds[i] > $proposal.cmds.length - 1) {
                revert TextDAOErrors.InvalidCommandId(repVote.rankedCommandIds[i]);
            }
        }
    }
}


// Testing
import {MCTest} from "@mc-devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

/**
 * @title Vote Contract Test
 * @dev Test suite for the Vote contract
 */
contract VoteTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;

    function setUp() public {
        _use(Vote.vote.selector, address(new Vote()));
    }

    /**
     * @notice Test successful voting
     * @dev Verifies that a valid vote is correctly recorded
     */
    function test_vote_success() public {
        (uint256 _pid, address _voter) = _setupProposalAndVoter();
        Schema.Vote memory _repVote = _createValidVote();

        vm.prank(_voter);
        Vote(target).vote(_pid, _repVote);

        _assertVoteRecorded(_pid, _voter, _repVote);
    }

    /**
     * @notice Test voting by non-representative
     * @dev Verifies that a non-representative cannot vote
     */
    function test_vote_revert_notRep() public {
        (uint256 _pid, ) = _setupProposalAndVoter();
        Schema.Vote memory _repVote = _createValidVote();

        address _nonRep = address(0xBEEF);
        vm.prank(_nonRep);
        vm.expectRevert(TextDAOErrors.YouAreNotTheRep.selector);
        Vote(target).vote(_pid, _repVote);
    }

    /**
     * @notice Test voting on an expired proposal
     * @dev Verifies that voting on an expired proposal is not allowed
     */
    function test_vote_revert_proposalExpired() public {
        (uint256 _pid, address _voter) = _setupProposalAndVoter();
        Schema.Proposal storage $testProposal = Storage.Deliberation().proposals[_pid];
        $testProposal.meta.expirationTime = block.timestamp - 1;

        Schema.Vote memory _repVote = _createValidVote();

        vm.prank(_voter);
        vm.expectRevert(TextDAOErrors.ProposalAlreadyExpired.selector);
        Vote(target).vote(_pid, _repVote);
    }

    /**
     * @notice Test voting with an invalid header ID
     * @dev Verifies that voting with an invalid header ID is not allowed
     */
    function test_vote_revert_invalidHeaderId() public {
        (uint256 _pid, address _voter) = _setupProposalAndVoter();
        Schema.Vote memory _repVote = _createValidVote();
        _repVote.rankedHeaderIds[2] = 10; // Invalid header ID

        vm.prank(_voter);
        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidHeaderId.selector, 10));
        Vote(target).vote(_pid, _repVote);
    }

    /**
     * @notice Test voting with an invalid command ID
     * @dev Verifies that voting with an invalid command ID is not allowed
     */
    function test_vote_revert_invalidCommandId() public {
        (uint256 _pid, address _voter) = _setupProposalAndVoter();
        Schema.Vote memory _repVote = _createValidVote();
        _repVote.rankedCommandIds[2] = 10; // Invalid command ID

        vm.prank(_voter);
        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidCommandId.selector, 10));
        Vote(target).vote(_pid, _repVote);
    }

    /**
     * @notice Test voting with duplicate header IDs
     * @dev Verifies that voting with duplicate header IDs is allowed (as per current implementation)
     */
    function test_vote_success_duplicateHeaderIds() public {
        (uint256 _pid, address _voter) = _setupProposalAndVoter();
        Schema.Vote memory _repVote = _createValidVote();
        _repVote.rankedHeaderIds = [uint256(1), 1, 1]; // Duplicate header IDs

        vm.prank(_voter);
        Vote(target).vote(_pid, _repVote);

        _assertVoteRecorded(_pid, _voter, _repVote);
    }

    /**
     * @notice Test voting with duplicate command IDs
     * @dev Verifies that voting with duplicate command IDs is allowed (as per current implementation)
     */
    function test_vote_success_duplicateCommandIds() public {
        (uint256 _pid, address _voter) = _setupProposalAndVoter();
        Schema.Vote memory _repVote = _createValidVote();
        _repVote.rankedCommandIds = [uint256(1), 1, 1]; // Duplicate command IDs

        vm.prank(_voter);
        Vote(target).vote(_pid, _repVote);

        _assertVoteRecorded(_pid, _voter, _repVote);
    }

    /**
     * @notice Test voting with zero values
     * @dev Verifies that voting with zero values for some choices is allowed and correctly recorded
     */
    function test_vote_success_withZeroValues() public {
        (uint256 _pid, address _voter) = _setupProposalAndVoter();
        Schema.Vote memory _repVote = Schema.Vote({
            rankedHeaderIds: [uint256(1), 0, 2],
            rankedCommandIds: [uint256(0), 1, 2]
        });

        vm.prank(_voter);
        Vote(target).vote(_pid, _repVote);

        _assertVoteRecorded(_pid, _voter, _repVote);
    }

    /**
     * @dev Sets up a proposal and a voter for testing
     * @return pid The ID of the created proposal
     * @return voter The address of the voter
     */
    function _setupProposalAndVoter() internal returns (uint256 pid, address voter) {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        pid = Storage.Deliberation().proposals.length - 1;

        for (uint256 i; i < 3; ++i) {
            $testProposal.createHeader("test://metadata");
            $testProposal.createCommand(new Schema.Action[](1));
        }

        voter = address(0x1234);
        $testProposal.meta.reps.push(voter);

        return (pid, voter);
    }

    /**
     * @dev Creates a valid vote for testing
     * @return A valid Schema.Vote structure
     */
    function _createValidVote() internal pure returns (Schema.Vote memory) {
        return Schema.Vote({
            rankedHeaderIds: [uint256(1), 2, 3],
            rankedCommandIds: [uint256(1), 2, 3]
        });
    }

    /**
     * @dev Asserts that a vote was correctly recorded
     * @param _pid The ID of the proposal
     * @param _voter The address of the voter
     * @param _expectedVote The expected vote structure
     */
    function _assertVoteRecorded(uint256 _pid, address _voter, Schema.Vote memory _expectedVote) internal view {
        Schema.Proposal storage $proposal = Storage.Deliberation().proposals[_pid];
        Schema.Vote memory _recordedVote = $proposal.meta.votes[_voter];

        for (uint256 i; i < 3; ++i) {
            assertEq(_recordedVote.rankedHeaderIds[i], _expectedVote.rankedHeaderIds[i],
                string(abi.encodePacked("Header ID mismatch at index ", vm.toString(i))));
            assertEq(_recordedVote.rankedCommandIds[i], _expectedVote.rankedCommandIds[i],
                string(abi.encodePacked("Command ID mismatch at index ", vm.toString(i))));
        }
    }
}
