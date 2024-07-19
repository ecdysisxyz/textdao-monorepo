// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

/**
 * @title RCVLib
 * @dev Library for Ranked Choice Voting (RCV) calculations and utilities
 * @notice This library provides functions to calculate scores and find top scorers in RCV
 * @custom:version 0.1.0
 */
library RCVLib {
    /**
    * @notice Calculates the scores for headers and commands based on ranked choice voting
    * @dev This function processes votes and calculates scores for each header and command option.
    *      It handles the following scenarios:
    *      - Assigns scores based on the ranking (3 points for 1st choice, 2 for 2nd, 1 for 3rd)
    *      - Ignores duplicate votes, only counting the highest score for each unique choice
    *      - Emits warning events for invalid (out-of-range) or duplicate choices
    *      - Properly handles cases with fewer than 3 choices
    *
    *      The resulting scores can be used with findTopScorer and findTop3Scorers functions
    *      to determine the winning option(s).
    *
    * @param $proposal The storage pointer to the proposal containing votes
    * @return headerScores An array of scores for headers, where the index represents the header ID
    * @return commandScores An array of scores for commands, where the index represents the command ID
    */
    function calcRCVScores(Schema.Proposal storage $proposal) internal returns(uint[] memory headerScores, uint[] memory commandScores) {
        headerScores = new uint[]($proposal.headers.length);
        commandScores = new uint[]($proposal.cmds.length);

        for (uint i; i < $proposal.meta.reps.length; ++i) {
            Schema.Vote memory _repVote = $proposal.meta.votes[$proposal.meta.reps[i]];

            // Process header votes
            uint _h1 = _repVote.rankedHeaderIds[0];
            uint _h2 = _repVote.rankedHeaderIds[1];
            uint _h3 = _repVote.rankedHeaderIds[2];

            uint _headerRange = headerScores.length;

            // Process first header
            if (!isWithinRange(_h1, _headerRange)) {
                emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(_h1);
            } else {
                headerScores[_h1] += 3;
            }

            // Process second header
            if (!isWithinRange(_h2, _headerRange)) {
                emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(_h2);
            } else if (_h2 == _h1) {
                emit TextDAOEvents.WARN_HeaderChoiceIsDuplicate(_h2);
            } else {
                headerScores[_h2] += 2;
            }

            // Process third header
            if (!isWithinRange(_h3, _headerRange)) {
                emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(_h3);
            } else if (_h3 == _h1 || _h3 == _h2) {
                emit TextDAOEvents.WARN_HeaderChoiceIsDuplicate(_h3);
            } else {
                headerScores[_h3] += 1;
            }

            // Process command votes
            uint _c1 = _repVote.rankedCommandIds[0];
            uint _c2 = _repVote.rankedCommandIds[1];
            uint _c3 = _repVote.rankedCommandIds[2];

            uint _commandRange = headerScores.length;

            // Process first command
            if (!isWithinRange(_c1, _commandRange)) {
                emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(_c1);
            } else {
                commandScores[_c1] += 3;
            }

            // Process second command
            if (!isWithinRange(_c2, _commandRange)) {
                emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(_c2);
            } else if (_c2 == _c1) {
                emit TextDAOEvents.WARN_CommandChoiceIsDuplicate(_c2);
            } else {
                commandScores[_c2] += 2;
            }

            // Process third command
            if (!isWithinRange(_c3, _commandRange)) {
                emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(_c3);
            } else if (_c3 == _c1 || _c3 == _c2) {
                emit TextDAOEvents.WARN_CommandChoiceIsDuplicate(_c3);
            } else {
                commandScores[_c3] += 1;
            }
        }
    }

    /**
    * @notice Checks if a choice is within the valid range
    * @dev A choice is valid if it's non-zero and less than the maximum value
    * @param choice The choice to check
    * @param range The maximum valid value for the choice
    * @return bool True if the choice is within range, false otherwise
    */
    function isWithinRange(uint choice, uint range) internal pure returns (bool) {
        return 0 < choice && choice < range;
    }

    /**
    * @notice Finds the indices of the highest scoring option(s)
    * @dev This function is designed to work with the scores calculated by calcRCVScores.
    *      It returns the index (or indices) of the highest scoring option(s).
    *      In case of a tie for the top score, all tied indices are returned.
    *      If all scores are zero, an empty array is returned.
    * @param scores Array of scores, where the index represents the candidate ID
    * @return topScorers Array of indices (candidate IDs) with the highest score.
    *         This array will contain multiple indices if there's a tie for the top score.
    *         It will be empty if all scores are zero.
    */
    function findTopScorer(uint[] memory scores) internal pure returns(uint[] memory topScorers) {
        uint _maxScore = 0;
        uint _count = 0;

        // Find max score and count occurrences
        for (uint i; i < scores.length; ++i) {
            if (scores[i] > _maxScore) {
                _maxScore = scores[i];
                _count = 1;
            } else if (scores[i] == _maxScore && _maxScore > 0) {
                _count++;
            }
        }

        // If all scores are zero, return an empty array
        if (_maxScore == 0) {
            return new uint[](0);
        }

        topScorers = new uint[](_count);
        uint _index = 0;

        // Collect indices with max score
        for (uint i; i < scores.length; ++i) {
            if (scores[i] == _maxScore) {
                topScorers[_index] = i;
                _index++;
            }
        }
    }

    /**
     * @notice Finds the indices of the top 3 highest scoring options
     * @dev This function is designed to work with the scores calculated by calcRCVScores.
     *      It returns the indices of the top 3 highest scoring options, including ties.
     *      The returned array may contain more than 3 indices if there are ties.
     *      For example, if there's a tie for 2nd place, it might return 4 indices:
     *      the 1st place and all candidates tied for 2nd.
     * @param scores Array of scores, where the index represents the candidate ID
     * @return top3Scorers Array of indices (candidate IDs) with the top 3 highest scores,
     *         including ties. The length of this array may exceed 3 in case of ties.
     */
    function findTop3Scorers(uint[] memory scores) internal pure returns(uint[] memory top3Scorers) {
        uint[3] memory _topScores = [uint(0), 0, 0];
        uint[3] memory _topIndices = [type(uint).max, type(uint).max, type(uint).max];
        uint _count = 0;

        for (uint i; i < scores.length; ++i) {
            if (scores[i] > _topScores[2]) {
                if (scores[i] > _topScores[1]) {
                    if (scores[i] > _topScores[0]) {
                        _topScores[2] = _topScores[1];
                        _topIndices[2] = _topIndices[1];
                        _topScores[1] = _topScores[0];
                        _topIndices[1] = _topIndices[0];
                        _topScores[0] = scores[i];
                        _topIndices[0] = i;
                    } else {
                        _topScores[2] = _topScores[1];
                        _topIndices[2] = _topIndices[1];
                        _topScores[1] = scores[i];
                        _topIndices[1] = i;
                    }
                } else {
                    _topScores[2] = scores[i];
                    _topIndices[2] = i;
                }
                if (_count < 3) _count++;
            }
        }

        top3Scorers = new uint[](_count);
        for (uint i; i < _count; ++i) {
            top3Scorers[i] = _topIndices[i];
        }
    }
}


// Testing
import {Test, console2} from "@devkit/Flattened.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {ProposalLib} from "bundle/textDAO/utils/ProposalLib.sol";

/**
 * @title RCVLibTest
 * @dev Test contract for the RCVLib library
 */
contract RCVLibTest is Test {
    using RCVLib for Schema.Proposal;
    using RCVLib for uint[];
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;

    // Fuzzing parameters
    uint256 internal constant MAX_REPS = 40;
    uint256 internal constant MAX_HEADERS = 100;
    uint256 internal constant MAX_COMMANDS = 100;

    /**
     * @notice Tests the RCV Score calculation for a proposal with specific votes
     * @dev Verifies that the votes are correctly calculated for both headers and commands
     */
    function test_calcRCVScores_success_withSpecificVotes() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();

        // Setup proposal
        for (uint i; i < 4; ++i) {
            $testProposal.createHeader("test://metadata");
            $testProposal.createCommand(new Schema.Action[](1));
        }

        // Setup votes
        $testProposal.meta.reps = new address[](3);
        $testProposal.meta.reps[0] = address(1);
        $testProposal.meta.reps[1] = address(2);
        $testProposal.meta.reps[2] = address(3);

        $testProposal.meta.votes[address(1)] = Schema.Vote(uintArray(4, 2, 1), uintArray(3, 2, 1));
        $testProposal.meta.votes[address(2)] = Schema.Vote(uintArray(2, 3, 2), uintArray(2, 4, 2)); // Note the duplicate votes
        $testProposal.meta.votes[address(3)] = Schema.Vote(uintArray(3, 1, 0), uintArray(1, 5, 3)); // Note the out-of-range votes

        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(0);
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(5);

        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();

        assertEq(_headerScores[0], 0, "Header 0 should have score 0");
        assertEq(_headerScores[1], 3, "Header 1 should have score 3");
        assertEq(_headerScores[2], 5, "Header 2 should have score 5");
        assertEq(_headerScores[3], 5, "Header 3 should have score 5");
        assertEq(_headerScores[4], 3, "Header 4 should have score 3");
        assertEq(_commandScores[0], 0, "Command 0 should have score 0");
        assertEq(_commandScores[1], 4, "Command 1 should have score 4");
        assertEq(_commandScores[2], 5, "Command 2 should have score 5");
        assertEq(_commandScores[3], 4, "Command 3 should have score 4");
        assertEq(_commandScores[4], 2, "Command 4 should have score 2");
    }

    /**
     * @notice Tests the RCV Score calculation for a proposal with random inputs
     * @dev Verifies vote calculation with various random inputs using fuzzing
     * @param numReps Number of representatives
     * @param seed Random seed for generating votes
     */
    function test_calcRCVScores_success_withRandomInputs(uint8 numReps, uint32 seed) public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        numReps = uint8(bound(numReps, 1, MAX_REPS));

        for (uint i; i < MAX_HEADERS; ++i) {
            $testProposal.createHeader("test://metadata");
        }
        for (uint i; i < MAX_COMMANDS; ++i) {
            Schema.Action[] memory _actions = new Schema.Action[](1);
            _actions[0] = Schema.Action("test()", "0x");
            $testProposal.createCommand(_actions);
        }

        for (uint i; i < numReps; ++i) {
            $testProposal.meta.reps.push(address(uint160(i + 1)));
            uint256 _randomSeed = uint256(keccak256(abi.encode(seed, i)));
            uint[3] memory _rankedHeaderIds;
            uint[3] memory _rankedCommandIds;

            for (uint j = 0; j < 3; j++) {
                _rankedHeaderIds[j] = (uint(keccak256(abi.encode(_randomSeed, "header", j))) % MAX_HEADERS) + 1;
                _rankedCommandIds[j] = (uint(keccak256(abi.encode(_randomSeed, "command", j))) % MAX_COMMANDS) + 1;
            }

            $testProposal.meta.votes[$testProposal.meta.reps[i]] = Schema.Vote({
                rankedHeaderIds: _rankedHeaderIds,
                rankedCommandIds: _rankedCommandIds
            });
        }

        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();

        assertEq(_headerScores.length, MAX_HEADERS + 1, "Header scores length should be MAX_HEADERS + 1");
        assertEq(_commandScores.length, MAX_COMMANDS + 1, "Command scores length should be MAX_COMMANDS + 1");

        uint[] memory _expectedHeaderScores = new uint[](MAX_HEADERS + 1);
        uint[] memory _expectedCommandScores = new uint[](MAX_COMMANDS + 1);

        for (uint i; i < numReps; ++i) {
            Schema.Vote memory vote = $testProposal.meta.votes[$testProposal.meta.reps[i]];

            uint _h1 = vote.rankedHeaderIds[0];
            uint _h2 = vote.rankedHeaderIds[1];
            uint _h3 = vote.rankedHeaderIds[2];

            if (RCVLib.isWithinRange(_h1, MAX_HEADERS + 1)) _expectedHeaderScores[_h1] += 3;
            if (RCVLib.isWithinRange(_h2, MAX_HEADERS + 1) && _h2 != _h1) _expectedHeaderScores[_h2] += 2;
            if (RCVLib.isWithinRange(_h3, MAX_HEADERS + 1) && _h3 != _h1 && _h3 != _h2) _expectedHeaderScores[_h3] += 1;

            uint _c1 = vote.rankedCommandIds[0];
            uint _c2 = vote.rankedCommandIds[1];
            uint _c3 = vote.rankedCommandIds[2];

            if (RCVLib.isWithinRange(_c1, MAX_COMMANDS + 1)) _expectedCommandScores[_c1] += 3;
            if (RCVLib.isWithinRange(_c2, MAX_COMMANDS + 1) && _c2 != _c1) _expectedCommandScores[_c2] += 2;
            if (RCVLib.isWithinRange(_c3, MAX_COMMANDS + 1) && _c3 != _c1 && _c3 != _c2) _expectedCommandScores[_c3] += 1;
        }

        for (uint i = 1; i <= MAX_HEADERS; ++i) {
            assertEq(_headerScores[i], _expectedHeaderScores[i],
                string.concat("Header ", vm.toString(i), " scores mismatch"));
            }
        for (uint i = 1; i <= MAX_COMMANDS; ++i) {
            assertEq(_commandScores[i], _expectedCommandScores[i],
                string.concat("Command ", vm.toString(i), " scores mismatch"));
        }

        assertEq(_headerScores[0], 0, "Header score at index 0 should be 0 (undefined)");
        assertEq(_commandScores[0], 0, "Command score at index 0 should be 0 (undefined)");
    }

    /**
     * @notice Tests the RCV Score calculation for an empty proposal
     * @dev Verifies that an empty proposal returns arrays of length 1 with zero votes
     */
    function test_calcRCVScores_emptyProposal() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();
        assertEq(_headerScores.length, 1, "Header scores should have length 1 for empty proposal");
        assertEq(_commandScores.length, 1, "Command scores should have length 1 for empty proposal");
        assertEq(_headerScores[0], 0, "Header scores should be zero for empty proposal");
        assertEq(_commandScores[0], 0, "Command scores should be zero for empty proposal");
    }

    /**
     * @notice Tests the RCV Score calculation for a proposal with maximum votes
     * @dev Verifies that a single vote results in maximum score for the voted options
     */
    function test_calcRCVScores_maxVotes() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();
        $testProposal.createHeader("test://metadata");
        $testProposal.createCommand(new Schema.Action[](1));
        $testProposal.meta.reps = new address[](1);
        $testProposal.meta.reps[0] = address(1);
        $testProposal.meta.votes[address(1)] = Schema.Vote(uintArray(1, 0, 0), uintArray(1, 0, 0));
        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();
        assertEq(_headerScores[1], 3, "Header votes should be maximum for single vote");
        assertEq(_commandScores[1], 3, "Command votes should be maximum for single vote");
    }

    /**
     * @notice Tests the RCV Score calculation with duplicate votes
     * @dev Verifies that duplicate votes are handled correctly
     */
    function test_calcRCVScores_duplicateVotes() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();

        for (uint i; i < 3; ++i) {
            $testProposal.createHeader("test://metadata");
            $testProposal.createCommand(new Schema.Action[](1));
        }

        $testProposal.meta.reps = new address[](1);
        $testProposal.meta.reps[0] = address(1);
        $testProposal.meta.votes[address(1)] = Schema.Vote(uintArray(1, 1, 1), uintArray(2, 2, 2));

        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();

        assertEq(_headerScores[1], 3, "Header 1 should have 3 votes (only the highest score)");
        assertEq(_headerScores[2], 0, "Header 2 should have 0 votes");
        assertEq(_commandScores[2], 3, "Command 2 should have 3 votes (only the highest score)");
        assertEq(_commandScores[1], 0, "Command 1 should have 0 votes");
    }

    /**
     * @notice Tests the RCV Score calculation with out-of-range votes
     * @dev Verifies that out-of-range votes are ignored
     */
    function test_calcRCVScores_outOfRangeVotes() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();

        for (uint i; i < 3; ++i) {
            $testProposal.createHeader("test://metadata");
            $testProposal.createCommand(new Schema.Action[](1));
        }

        $testProposal.meta.reps = new address[](1);
        $testProposal.meta.reps[0] = address(1);
        $testProposal.meta.votes[address(1)] = Schema.Vote(uintArray(4, 5, 1), uintArray(0, 1, 4));

        vm.expectEmit();
        emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(4);
        emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(5);
        emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(0);
        emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(4);
        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();

        assertEq(_headerScores[0], 0, "Header 0 should have score 0");
        assertEq(_headerScores[1], 1, "Header 1 should have score 1");
        assertEq(_headerScores[2], 0, "Header 2 should have score 0");
        assertEq(_headerScores[3], 0, "Header 3 should have score 0");
        assertEq(_commandScores[0], 0, "Command 0 (invalid) should have score 0");
        assertEq(_commandScores[1], 2, "Command 1 should have score 2");
        assertEq(_commandScores[2], 0, "Command 2 should have score 0");
        assertEq(_commandScores[3], 0, "Command 3 should have score 0");
    }

    /**
     * @notice Tests the RCV Score calculation when all votes are invalid
     * @dev This edge case checks the behavior when every vote is out of range
     *      It ensures that:
     *      1. Appropriate warning events are emitted for each invalid vote
     *      2. No scores are awarded for any invalid votes
     */
    function test_calcRCVScores_allInvalidVotes() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();

        // Setup proposal with 3 headers and commands
        for (uint i; i < 3; ++i) {
            $testProposal.createHeader("test://metadata");
            $testProposal.createCommand(new Schema.Action[](1));
        }

        // Setup a single representative with all invalid votes
        $testProposal.meta.reps = new address[](1);
        $testProposal.meta.reps[0] = address(1);
        $testProposal.meta.votes[address(1)] = Schema.Vote(uintArray(0, 4, 5), uintArray(0, 4, 5));

        // Expect warning events for each invalid vote
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(0);
        emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(4);
        emit TextDAOEvents.WARN_HeaderChoiceIsOutOfRange(5);
        emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(0);
        emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(4);
        emit TextDAOEvents.WARN_CommandChoiceIsOutOfRange(5);

        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();

        // Verify that no votes were counted
        for (uint i; i < _headerScores.length; ++i) {
            assertEq(_headerScores[i], 0, string.concat("Header ", vm.toString(i), " should have 0 scores"));
        }
        for (uint i; i < _commandScores.length; ++i) {
            assertEq(_commandScores[i], 0, string.concat("Command ", vm.toString(i), " should have 0 scores"));
        }
    }

    /**
     * @notice Tests the RCV Score calculation when all votes are duplicates
     * @dev This edge case checks the behavior when every vote is a duplicate
     *      It ensures that:
     *      1. Appropriate warning events are emitted for duplicate votes
     *      2. Only the highest score is awarded for duplicate votes
     */
    function test_calcRCVScores_allDuplicateVotes() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();

        // Setup proposal with 3 headers and commands
        for (uint i; i < 3; ++i) {
            $testProposal.createHeader("test://metadata");
            $testProposal.createCommand(new Schema.Action[](1));
        }

        // Setup a single representative with all duplicate votes
        $testProposal.meta.reps = new address[](1);
        $testProposal.meta.reps[0] = address(1);
        $testProposal.meta.votes[address(1)] = Schema.Vote(uintArray(1, 1, 1), uintArray(2, 2, 2));

        // Expect warning events for duplicate votes
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.WARN_HeaderChoiceIsDuplicate(1);
        emit TextDAOEvents.WARN_HeaderChoiceIsDuplicate(1);
        emit TextDAOEvents.WARN_CommandChoiceIsDuplicate(2);
        emit TextDAOEvents.WARN_CommandChoiceIsDuplicate(2);

        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();

        // Verify that only the highest score was awarded for duplicates
        assertEq(_headerScores[1], 3, "Header 1 should have 3 scores (only the highest score)");
        assertEq(_commandScores[2], 3, "Command 2 should have 3 scores (only the highest score)");
    }

    /**
     * @notice Tests the RCV Score calculation with maximum inputs
     * @dev This edge case checks the behavior when the system is at maximum capacity
     *      It ensures that:
     *      1. The system can handle the maximum number of representatives, headers, and commands
     *      2. Votes are correctly tallied even at maximum capacity
     */
    function test_calcRCVScores_maxInputs() public {
        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();

        // Setup proposal with maximum number of headers and commands
        for (uint i; i < MAX_HEADERS; ++i) {
            $testProposal.createHeader("test://metadata");
        }
        for (uint i; i < MAX_COMMANDS; ++i) {
            $testProposal.createCommand(new Schema.Action[](1));
        }

        // Setup maximum number of representatives, each voting for the first three options
        for (uint i; i < MAX_REPS; ++i) {
            $testProposal.meta.reps.push(address(uint160(i + 1)));
            $testProposal.meta.votes[$testProposal.meta.reps[i]] = Schema.Vote({
                rankedHeaderIds: uintArray(1, 2, 3),
                rankedCommandIds: uintArray(1, 2, 3)
            });
        }

        (uint[] memory _headerScores, uint[] memory _commandScores) = $testProposal.calcRCVScores();

        // Verify that the system correctly handled maximum inputs
        assertEq(_headerScores.length, MAX_HEADERS + 1, "Header scores length should be MAX_HEADERS + 1");
        assertEq(_commandScores.length, MAX_COMMANDS + 1, "Command scores length should be MAX_COMMANDS + 1");
        assertEq(_headerScores[1], MAX_REPS * 3, "Header 1 should have MAX_REPS * 3 scores");
        assertEq(_commandScores[1], MAX_REPS * 3, "Command 1 should have MAX_REPS * 3 scores");
    }

    /**
    * @notice Tests the gas cost of RCV Score calculation for different input sizes
    * @dev Verifies that the gas cost is within acceptable limits for various input sizes
    * @param numReps Number of representatives (1 to MAX_REPS)
    * @param numHeaders Number of headers (3 to MAX_HEADERS)
    * @param numCommands Number of commands (3 to MAX_COMMANDS)
    */
    function test_calcRCVScores_gasConsumption(uint8 numReps, uint8 numHeaders, uint8 numCommands) public {
        numReps = uint8(bound(numReps, 1, MAX_REPS));
        numHeaders = uint8(bound(numHeaders, 3, MAX_HEADERS));
        numCommands = uint8(bound(numCommands, 3, MAX_COMMANDS));

        Schema.Proposal storage $testProposal = Storage.Deliberation().createProposal();

        for (uint i; i < numHeaders; ++i) {
            $testProposal.createHeader("test://metadata");
        }
        for (uint i; i < numCommands; ++i) {
            Schema.Action[] memory _actions = new Schema.Action[](1);
            _actions[0] = Schema.Action("test()", "0x");
            $testProposal.createCommand(_actions);
        }

        for (uint i; i < numReps; ++i) {
            $testProposal.meta.reps.push(address(uint160(i + 1)));
            $testProposal.meta.votes[$testProposal.meta.reps[i]] = Schema.Vote({
                rankedHeaderIds: uintArray(1, 2, 3),
                rankedCommandIds: uintArray(1, 2, 3)
            });
        }

        uint256 gasStart = gasleft();
        $testProposal.calcRCVScores();
        uint256 gasUsed = gasStart - gasleft();

        uint256 baseGas = 50000;
        uint256 perRepGas = 5000;
        uint256 perChoiceGas = 1000;
        uint256 expectedMaxGas = baseGas + (numReps * perRepGas) + ((numHeaders + numCommands) * perChoiceGas);

        assertLt(gasUsed, expectedMaxGas, "Gas usage exceeds expected maximum");
    }

    /**
     * @notice Tests finding the top scorer with a single maximum value
     * @dev Verifies that the function correctly identifies a single top scorer
     */
    function test_findTopScorer_singleMax() public pure {
        uint[] memory _scores = new uint[](5);
        _scores[0] = 10;
        _scores[1] = 5;
        _scores[2] = 15;
        _scores[3] = 8;
        _scores[4] = 12;

        uint[] memory result = _scores.findTopScorer();
        assertEq(result.length, 1, "Should find only one top scorer");
        assertEq(result[0], 2, "Top scorer should be at index 2");
    }

    /**
     * @notice Tests finding the top scorer with multiple maximum values
     * @dev Verifies that the function correctly identifies multiple top scorers
     */
    function test_findTopScorer_multipleMax() public pure {
        uint[] memory _scores = new uint[](5);
        _scores[0] = 15;
        _scores[1] = 10;
        _scores[2] = 15;
        _scores[3] = 8;
        _scores[4] = 15;

        uint[] memory _result = _scores.findTopScorer();
        assertEq(_result.length, 3, "Should find three top scorers");
        assertEq(_result[0], 0, "First top scorer should be at index 0");
        assertEq(_result[1], 2, "Second top scorer should be at index 2");
        assertEq(_result[2], 4, "Third top scorer should be at index 4");
    }

    /**
    * @notice Tests finding the top scorer when all scores are zero
    * @dev Verifies that the function correctly handles the case where all scores are zero
    */
    function test_findTopScorer_allZeroScores() public pure {
        uint[] memory _scores = new uint[](5);
        // All scores are initialized to 0 by default

        uint[] memory result = _scores.findTopScorer();
        assertEq(result.length, 0, "Should find no top scorers when all scores are zero");
    }

    /**
     * @notice Tests finding the top 3 scorers with distinct values
     * @dev Verifies that the function correctly identifies the top 3 scorers
     */
    function test_findTop3Scorers_distinctValues() public pure {
        uint[] memory _scores = new uint[](5);
        _scores[0] = 10;
        _scores[1] = 5;
        _scores[2] = 15;
        _scores[3] = 8;
        _scores[4] = 12;

        uint[] memory _result = _scores.findTop3Scorers();
        assertEq(_result.length, 3, "Should find three top scorers");
        assertEq(_result[0], 2, "First top scorer should be at index 2");
        assertEq(_result[1], 4, "Second top scorer should be at index 4");
        assertEq(_result[2], 0, "Third top scorer should be at index 0");
    }

    /**
     * @notice Tests finding the top 3 scorers with tied values
     * @dev Verifies that the function correctly handles tied scores
     */
    function test_findTop3Scorers_tiedValues() public pure {
        uint[] memory _scores = new uint[](5);
        _scores[0] = 15;
        _scores[1] = 10;
        _scores[2] = 15;
        _scores[3] = 10;
        _scores[4] = 15;

        uint[] memory _result = _scores.findTop3Scorers();
        assertEq(_result.length, 3, "Should find three top scorers");
        assertEq(_result[0], 0, "First top scorer should be at index 0");
        assertEq(_result[1], 2, "Second top scorer should be at index 2");
        assertEq(_result[2], 4, "Third top scorer should be at index 4");
    }

    /**
     * @notice Tests finding the top 3 scorers with less than 3 non-zero scores
     * @dev Verifies that the function correctly handles cases with fewer than 3 non-zero scores
     */
    function test_findTop3Scorers_lessThanThree() public pure {
        uint[] memory _scores = new uint[](5);
        _scores[0] = 15;
        _scores[1] = 0;
        _scores[2] = 10;
        _scores[3] = 0;
        _scores[4] = 0;

        uint[] memory _result = _scores.findTop3Scorers();
        assertEq(_result.length, 2, "Should find two top scorers");
        assertEq(_result[0], 0, "First top scorer should be at index 0");
        assertEq(_result[1], 2, "Second top scorer should be at index 2");
    }

    /**
    * @notice Tests finding the top 3 scorers when all scores are zero
    * @dev Verifies that the function correctly handles the case where all scores are zero
    */
    function test_findTop3Scorers_allZeroScores() public pure {
        uint[] memory _scores = new uint[](5);
        // All scores are initialized to 0 by default

        uint[] memory result = _scores.findTop3Scorers();
        assertEq(result.length, 0, "Should find no top scorers when all scores are zero");
    }

    // Helper function to create uint256[3] arrays
    function uintArray(uint256 a, uint256 b, uint256 c) internal pure returns (uint256[3] memory) {
        return [a, b, c];
    }
}
