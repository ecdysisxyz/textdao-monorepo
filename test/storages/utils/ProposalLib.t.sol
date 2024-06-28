// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";
import {ProposalLib} from "bundle/textDAO/storages/utils/ProposalLib.sol";
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/storages/utils/DeliberationLib.sol";

contract ProposalLibTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;

    // Fuzzing parameters
    uint constant MAX_HEADERS = 10;
    uint constant MAX_COMMANDS = 10;
    uint constant MAX_REPS = 20;

    /**
     * @dev Test calcVotes method with a specific voting scenario
     */
    function test_calcVotes_withSpecificVotes() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        // Initialize the proposal with 3 headers and commands for specific tests
        for (uint i; i < 3; i++) {
            $proposal.headers.push();
            $proposal.cmds.push();
            $proposal.meta.reps.push(vm.addr(i+1));
        }

        // Set up specific voting data
        $proposal.meta.votes[vm.addr(1)] = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 3],
            rankedCommandIds: [uint(1), 2, 3]
        });
        $proposal.meta.votes[vm.addr(2)] = Schema.Vote({
            rankedHeaderIds: [uint(2), 1, 3],
            rankedCommandIds: [uint(2), 1, 3]
        });
        $proposal.meta.votes[vm.addr(3)] = Schema.Vote({
            rankedHeaderIds: [uint(3), 2, 1],
            rankedCommandIds: [uint(3), 2, 1]
        });

        // Call calcVotes method
        (uint[] memory _headerVotes, uint[] memory _commandVotes) = $proposal.calcVotes();

        // Verify results
        assertEq(_headerVotes.length, 4, "Header votes length should be 4 (available vote count is 3)");
        assertEq(_commandVotes.length, 4, "Command votes length should be 4 (available vote count is 3)");

        // Verify header voting results
        assertEq(_headerVotes[1], 6, "Header 1 should have 6 votes");
        assertEq(_headerVotes[2], 7, "Header 2 should have 7 votes");
        assertEq(_headerVotes[3], 5, "Header 3 should have 5 votes");

        // Verify command voting results
        assertEq(_commandVotes[1], 6, "Command 1 should have 6 votes");
        assertEq(_commandVotes[2], 7, "Command 2 should have 7 votes");
        assertEq(_commandVotes[3], 5, "Command 3 should have 5 votes");
    }

    /**
     * @dev Fuzz test for calcVotes method with random inputs
     * @param numReps Number of representatives (bounded between 1 and MAX_REPS)
     * @param seed Random seed for generating votes
     */
    function test_calcVotes_withRandomInputs(uint8 numReps, uint32 seed) public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        // Initialize headers and commands
        for (uint i = 0; i < MAX_HEADERS; i++) {
            $proposal.headers.push();
        }
        for (uint i = 0; i < MAX_COMMANDS; i++) {
            $proposal.cmds.push();
        }

        // Bound the number of representatives
        numReps = uint8(bound(numReps, 1, MAX_REPS));

        // Generate random votes for each representative
        for (uint i = 0; i < numReps; i++) {
            $proposal.meta.reps.push(address(uint160(i + 1)));
            uint256 randomSeed = uint256(keccak256(abi.encode(seed, i)));

            uint[3] memory rankedHeaderIds;
            uint[3] memory rankedCommandIds;

            for (uint j = 0; j < 3; j++) {
                rankedHeaderIds[j] = (uint(keccak256(abi.encode(randomSeed, "header", j))) % MAX_HEADERS) + 1;
                rankedCommandIds[j] = (uint(keccak256(abi.encode(randomSeed, "command", j))) % MAX_COMMANDS) + 1;
            }

            $proposal.meta.votes[$proposal.meta.reps[i]] = Schema.Vote({
                rankedHeaderIds: rankedHeaderIds,
                rankedCommandIds: rankedCommandIds
            });
        }

        // Call calcVotes method and verify results
        (uint[] memory headerVotes, uint[] memory commandVotes) = $proposal.calcVotes();

        assertEq(headerVotes.length, MAX_HEADERS + 1, "Header votes length should be MAX_HEADERS + 1");
        assertEq(commandVotes.length, MAX_COMMANDS + 1, "Command votes length should be MAX_COMMANDS + 1");

        // Calculate expected votes and compare results
        uint[] memory expectedHeaderVotes = new uint[](MAX_HEADERS + 1);
        uint[] memory expectedCommandVotes = new uint[](MAX_COMMANDS + 1);

        for (uint i = 0; i < numReps; i++) {
            Schema.Vote memory vote = $proposal.meta.votes[$proposal.meta.reps[i]];

            for (uint j = 0; j < 3; j++) {
                if (vote.rankedHeaderIds[j] > 0 && vote.rankedHeaderIds[j] <= MAX_HEADERS) {
                    expectedHeaderVotes[vote.rankedHeaderIds[j]] += 3 - j;
                }
                if (vote.rankedCommandIds[j] > 0 && vote.rankedCommandIds[j] <= MAX_COMMANDS) {
                    expectedCommandVotes[vote.rankedCommandIds[j]] += 3 - j;
                }
            }
        }

        for (uint i = 1; i <= MAX_HEADERS; i++) {
            assertEq(headerVotes[i], expectedHeaderVotes[i],
                string.concat("Header ", vm.toString(i), " votes mismatch"));
        }
        for (uint i = 1; i <= MAX_COMMANDS; i++) {
            assertEq(commandVotes[i], expectedCommandVotes[i],
                string.concat("Command ", vm.toString(i), " votes mismatch"));
        }

        // Verify that index 0 is always 0 (undefined)
        assertEq(headerVotes[0], 0, "Header votes at index 0 should be 0 (undefined)");
        assertEq(commandVotes[0], 0, "Command votes at index 0 should be 0 (undefined)");
    }
}
