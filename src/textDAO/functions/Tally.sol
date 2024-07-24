// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {ProposalLib} from "bundle/textDAO/utils/ProposalLib.sol";
import {RCVLib} from "bundle/textDAO/utils/RCVLib.sol";
// Interface
import {ITally} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

/**
 * @title Tally
 * @notice This contract handles the tallying process for proposals in TextDAO
 * @dev This contract is designed to be called by anyone, including keepers for automated execution
 */
contract Tally is ITally {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;
    using RCVLib for Schema.Proposal;
    using RCVLib for uint[];

    /**
     * @notice Initiates the tallying process for a given proposal
     * @param pid The ID of the proposal to tally
     * @dev This function can be called by anyone, including keepers
     * @dev If the proposal is expired, it performs the final tally. Otherwise, it takes a snapshot.
     */
    function tally(uint pid) external {
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);

        if ($proposal.isExpired()) {
            _finalTally(pid, $proposal);
        } else {
            _snap(pid, $proposal);
        }
    }

    /**
     * @notice Performs the final tally for a proposal
     * @param pid The ID of the proposal
     * @param $proposal The storage pointer to the proposal
     * @dev This function is called when the proposal has expired
     * @dev It calculates votes, finds the top header and command, and approves them
     * @dev If there's a tie, it extends the expiration time
     */
    function _finalTally(uint pid, Schema.Proposal storage $proposal) internal {
        if ($proposal.isApproved()) revert TextDAOErrors.ProposalAlreadyApproved();

        (uint[] memory _headerScores, uint[] memory _commandScores) = $proposal.calcRCVScores();

        uint[] memory _topHeaderIds = _headerScores.findTopScorer();
        uint[] memory _topCommandIds = _commandScores.findTopScorer();

        // If there's a tie or no votes, extend the expiration time and emit an event
        if (_topHeaderIds.length == 0 ||    // no votes for header
            _topCommandIds.length == 0 ||   // no votes for command
            _topHeaderIds.length > 1 || // there's a tie header
            _topCommandIds.length > 1   // there's a tie command
        ) {
            $proposal.meta.expirationTime += Storage.Deliberation().config.expiryDuration;
            emit TextDAOEvents.ProposalTalliedWithTie(pid, _topHeaderIds, _topCommandIds, $proposal.meta.expirationTime);
        } else {
            // Approve the winning header and command
            $proposal.approveHeader(_topHeaderIds[0]);
            $proposal.approveCommand(_topCommandIds[0]);
            emit TextDAOEvents.ProposalTallied(pid, _topHeaderIds[0], _topCommandIds[0]);
        }
    }

    /**
     * @notice Takes a snapshot of the current voting state
     * @param pid The ID of the proposal
     * @param $proposal The storage pointer to the proposal
     * @dev This function is called when the proposal has not yet expired
     * @dev It calculates the current top 3 headers and commands and emits an event
     * @dev Epoch is a rounded block.timestamp by snap interval
     */
    function _snap(uint pid, Schema.Proposal storage $proposal) internal {
        if ($proposal.isSnappedInEpoch()) revert TextDAOErrors.AlreadySnapped();

        (uint[] memory _headerScores, uint[] memory _commandScores) = $proposal.calcRCVScores();

        uint[] memory _top3HeaderIds = _headerScores.findTop3Scorers();
        uint[] memory _top3CommandIds = _commandScores.findTop3Scorers();

        $proposal.flagSnappedInEpoch();

        emit TextDAOEvents.ProposalSnapped(pid, _top3HeaderIds, _top3CommandIds);
    }
}


/// Testing
import {MCTest} from "@devkit/Flattened.sol";

/**
 * @title TallyTest
 * @notice Test contract for the Tally contract
 */
contract TallyTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;

    function setUp() public {
        _use(Tally.tally.selector, address(new Tally()));
    }

    /**
     * @notice Test successful final tally
     * @dev This test checks if the tally function correctly identifies and approves
     *      the winning header (ID: 1) and command (ID: 3) based on the votes set up
     *      in _setupProposalForTesting
     */
    function test_tally_finalTally_success() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        Schema.ProposalMeta storage $proposalMeta = $proposal.meta;

        _setupProposalForTesting($proposal, $proposalMeta);

        $proposalMeta.expirationTime = block.timestamp - 1;

        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTallied(0, 1, 3);
        Tally(target).tally(0);

        assertEq($proposalMeta.approvedHeaderId, 1, "Incorrect approved header ID");
        assertEq($proposalMeta.approvedCommandId, 3, "Incorrect approved command ID");
    }

    /**
     * @notice Test tally with tie
     * @dev This test creates a tie situation by adding a third vote that changes
     *      the scores. After adding this vote, the scores are:
     *      Headers: 1: 8 points, 2: 5 points, 3: 8 points, 4: 1 point
     *      Commands: 1: 5 points, 2: 4 points, 3: 6 points
     *      This results in a tie for headers (IDs 1 and 3), but not for commands (ID 3 still wins)
     */
    function test_tally_finalTally_success_tie() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        Schema.ProposalMeta storage $proposalMeta = $proposal.meta;

        _setupProposalForTesting($proposal, $proposalMeta);

        // Add another vote to create a tie
        $proposalMeta.reps.push(address(3));
        $proposalMeta.votes[address(3)].rankedHeaderIds = [2, 3, 1]; // This creates a tie between header 1 and 3
        $proposalMeta.votes[address(3)].rankedCommandIds = [1, 1, 1]; // This doesn't change the winning command

        $proposalMeta.expirationTime = block.timestamp - 1;

        uint _initialExpirationTime = $proposalMeta.expirationTime;
        uint _extendedExpirationTime = _initialExpirationTime + Storage.Deliberation().config.expiryDuration;

        uint[] memory _tieHeaderIds = new uint[](2);
        _tieHeaderIds[0] = 1;
        _tieHeaderIds[1] = 3;
        uint[] memory _tieCommandIds = new uint[](1);
        _tieCommandIds[0] = 3;

        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTalliedWithTie(0, _tieHeaderIds, _tieCommandIds, _extendedExpirationTime);
        Tally(target).tally(0);

        assertEq($proposalMeta.expirationTime, _extendedExpirationTime, "Expiration time should be extended");
        assertEq($proposalMeta.approvedHeaderId, 0, "No header should be approved in case of tie");
        assertEq($proposalMeta.approvedCommandId, 0, "No command should be approved in case of tie");
    }

    /**
     * @notice Test tally with no votes
     */
    function test_tally_finalTally_noVotes() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        Schema.ProposalMeta storage $proposalMeta = $proposal.meta;

        for (uint i; i < 3; i++) {
            $proposal.createHeader("test://metadata");
            $proposal.createCommand(new Schema.Action[](0));
        }

        $proposalMeta.expirationTime = block.timestamp - 1;

        uint _initialExpirationTime = $proposalMeta.expirationTime;
        uint _extendedExpirationTime = _initialExpirationTime + Storage.Deliberation().config.expiryDuration;

        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTalliedWithTie(0, new uint[](0), new uint[](0), _extendedExpirationTime);
        Tally(target).tally(0);

        assertEq($proposalMeta.expirationTime, _extendedExpirationTime, "Expiration time should be extended");
        assertEq($proposalMeta.approvedHeaderId, 0, "No header should be approved when there are no votes");
        assertEq($proposalMeta.approvedCommandId, 0, "No command should be approved when there are no votes");
    }

    /**
     * @notice Test tally with already approved proposal
     */
    function test_tally_finalTally_revert_alreadyApproved() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        Schema.ProposalMeta storage $proposalMeta = $proposal.meta;

        _setupProposalForTesting($proposal, $proposalMeta);

        $proposalMeta.expirationTime = block.timestamp - 1;
        $proposalMeta.approvedHeaderId = 1; // Set as already approved

        vm.expectRevert(TextDAOErrors.ProposalAlreadyApproved.selector);
        Tally(target).tally(0);
    }

    /**
     * @notice Test successful snapshot
     */
    function test_tally_snap_success() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        Schema.ProposalMeta storage $proposalMeta = $proposal.meta;

        _setupProposalForTesting($proposal, $proposalMeta);

        $proposalMeta.expirationTime = block.timestamp + 1;

        uint[] memory _top3HeaderIdsExpected = new uint[](3);
        _top3HeaderIdsExpected[0] = 1;
        _top3HeaderIdsExpected[1] = 3;
        _top3HeaderIdsExpected[2] = 2;
        uint[] memory _top3CommandIdsExpected = new uint[](3);
        _top3CommandIdsExpected[0] = 3;
        _top3CommandIdsExpected[1] = 2;
        _top3CommandIdsExpected[2] = 1;

        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalSnapped(0, _top3HeaderIdsExpected, _top3CommandIdsExpected);
        Tally(target).tally(0);

        assertFalse($proposal.isApproved(), "Proposal should not be approved after snapshot");
    }

    /**
     * @notice Test snapshot with already snapped proposal
     */
    function test_tally_snap_revert_alreadySnapped() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        Schema.ProposalMeta storage $proposalMeta = $proposal.meta;

        _setupProposalForTesting($proposal, $proposalMeta);

        $proposalMeta.expirationTime = block.timestamp + 1;
        $proposal.flagSnappedInEpoch(); // Set as already snapped

        vm.expectRevert(TextDAOErrors.AlreadySnapped.selector);
        Tally(target).tally(0);
    }

    /**
     * @notice Helper function to set up a proposal for testing
     * @dev This function creates a proposal with the following setup:
     * - 10 headers and commands (index 0 is not used)
     * - 2 representatives (address(1) and address(2))
     * - Votes are set up as follows:
     *   For headers:
     *     address(1): [1, 2, 3] (3 points for 1, 2 points for 2, 1 point for 3)
     *     address(2): [3, 1, 4] (3 points for 3, 2 points for 1, 1 point for 4)
     *   For commands:
     *     Both address(1) and address(2): [3, 2, 1]
     *
     * Resulting scores:
     * Headers: 1: 5 points, 2: 2 points, 3: 4 points, 4: 1 point
     * Commands: 1: 2 points, 2: 4 points, 3: 6 points, 4: 0 point
     *
     * Expected winners:
     * Header: 1 (with 5 points)
     * Command: 3 (with 6 points)
     */
    function _setupProposalForTesting(Schema.Proposal storage $testProposal, Schema.ProposalMeta storage $proposalMeta) internal {
        for (uint i; i < 10; i++) {
            $testProposal.createHeader("test://metadata");
            $testProposal.createCommand(new Schema.Action[](1));
        }
        $proposalMeta.reps.push(address(1));
        $proposalMeta.reps.push(address(2));
        $proposalMeta.votes[address(1)].rankedHeaderIds = [1, 2, 3];
        $proposalMeta.votes[address(2)].rankedHeaderIds = [3, 1, 4];
        $proposalMeta.votes[address(1)].rankedCommandIds = [3, 2, 1];
        $proposalMeta.votes[address(2)].rankedCommandIds = [3, 2, 1];
    }
}
