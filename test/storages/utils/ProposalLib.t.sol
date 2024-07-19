// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import {MCTest, console2} from "@devkit/Flattened.sol";
// import {ProposalLib} from "bundle/textDAO/utils/ProposalLib.sol";
// import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
// import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
// import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

// contract ProposalLibTest is MCTest {
//     using DeliberationLib for Schema.Deliberation;
//     using ProposalLib for Schema.Proposal;

//     // Fuzzing parameters
//     uint constant MAX_HEADERS = 10;
//     uint constant MAX_COMMANDS = 10;
//     uint constant MAX_REPS = 20;

//     /**
//      * @dev Test calcVotes method with a specific voting scenario
//      */
//     function test_calcVotes_withSpecificVotes() public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         // Initialize the proposal with 3 headers and commands for specific tests
//         for (uint i; i < 3; i++) {
//             $proposal.headers.push();
//             $proposal.cmds.push();
//             $proposal.meta.reps.push(vm.addr(i+1));
//         }

//         // Set up specific voting data
//         $proposal.meta.votes[vm.addr(1)] = Schema.Vote({
//             rankedHeaderIds: [uint(1), 2, 3],
//             rankedCommandIds: [uint(1), 2, 3]
//         });
//         $proposal.meta.votes[vm.addr(2)] = Schema.Vote({
//             rankedHeaderIds: [uint(2), 1, 3],
//             rankedCommandIds: [uint(2), 1, 3]
//         });
//         $proposal.meta.votes[vm.addr(3)] = Schema.Vote({
//             rankedHeaderIds: [uint(3), 2, 1],
//             rankedCommandIds: [uint(3), 2, 1]
//         });

//         // Call calcVotes method
//         (uint[] memory _headerVotes, uint[] memory _commandVotes) = $proposal.calcVotes();

//         // Verify results
//         assertEq(_headerVotes.length, 4, "Header votes length should be 4 (available vote count is 3)");
//         assertEq(_commandVotes.length, 4, "Command votes length should be 4 (available vote count is 3)");

//         // Verify header voting results
//         assertEq(_headerVotes[1], 6, "Header 1 should have 6 votes");
//         assertEq(_headerVotes[2], 7, "Header 2 should have 7 votes");
//         assertEq(_headerVotes[3], 5, "Header 3 should have 5 votes");

//         // Verify command voting results
//         assertEq(_commandVotes[1], 6, "Command 1 should have 6 votes");
//         assertEq(_commandVotes[2], 7, "Command 2 should have 7 votes");
//         assertEq(_commandVotes[3], 5, "Command 3 should have 5 votes");
//     }

//     /**
//      * @dev Fuzz test for calcVotes method with random inputs
//      * @param numReps Number of representatives (bounded between 1 and MAX_REPS)
//      * @param seed Random seed for generating votes
//      */
//     function test_calcVotes_withRandomInputs(uint8 numReps, uint32 seed) public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         // Initialize headers and commands
//         for (uint i = 0; i < MAX_HEADERS; i++) {
//             $proposal.headers.push();
//         }
//         for (uint i = 0; i < MAX_COMMANDS; i++) {
//             $proposal.cmds.push();
//         }

//         // Bound the number of representatives
//         numReps = uint8(bound(numReps, 1, MAX_REPS));

//         // Generate random votes for each representative
//         for (uint i = 0; i < numReps; i++) {
//             $proposal.meta.reps.push(address(uint160(i + 1)));
//             uint256 randomSeed = uint256(keccak256(abi.encode(seed, i)));

//             uint[3] memory rankedHeaderIds;
//             uint[3] memory rankedCommandIds;

//             for (uint j = 0; j < 3; j++) {
//                 rankedHeaderIds[j] = (uint(keccak256(abi.encode(randomSeed, "header", j))) % MAX_HEADERS) + 1;
//                 rankedCommandIds[j] = (uint(keccak256(abi.encode(randomSeed, "command", j))) % MAX_COMMANDS) + 1;
//             }

//             $proposal.meta.votes[$proposal.meta.reps[i]] = Schema.Vote({
//                 rankedHeaderIds: rankedHeaderIds,
//                 rankedCommandIds: rankedCommandIds
//             });
//         }

//         // Call calcVotes method and verify results
//         (uint[] memory headerVotes, uint[] memory commandVotes) = $proposal.calcVotes();

//         assertEq(headerVotes.length, MAX_HEADERS + 1, "Header votes length should be MAX_HEADERS + 1");
//         assertEq(commandVotes.length, MAX_COMMANDS + 1, "Command votes length should be MAX_COMMANDS + 1");

//         // Calculate expected votes and compare results
//         uint[] memory expectedHeaderVotes = new uint[](MAX_HEADERS + 1);
//         uint[] memory expectedCommandVotes = new uint[](MAX_COMMANDS + 1);

//         for (uint i = 0; i < numReps; i++) {
//             Schema.Vote memory vote = $proposal.meta.votes[$proposal.meta.reps[i]];

//             for (uint j = 0; j < 3; j++) {
//                 if (vote.rankedHeaderIds[j] > 0 && vote.rankedHeaderIds[j] <= MAX_HEADERS) {
//                     expectedHeaderVotes[vote.rankedHeaderIds[j]] += 3 - j;
//                 }
//                 if (vote.rankedCommandIds[j] > 0 && vote.rankedCommandIds[j] <= MAX_COMMANDS) {
//                     expectedCommandVotes[vote.rankedCommandIds[j]] += 3 - j;
//                 }
//             }
//         }

//         for (uint i = 1; i <= MAX_HEADERS; i++) {
//             assertEq(headerVotes[i], expectedHeaderVotes[i],
//                 string.concat("Header ", vm.toString(i), " votes mismatch"));
//         }
//         for (uint i = 1; i <= MAX_COMMANDS; i++) {
//             assertEq(commandVotes[i], expectedCommandVotes[i],
//                 string.concat("Command ", vm.toString(i), " votes mismatch"));
//         }

//         // Verify that index 0 is always 0 (undefined)
//         assertEq(headerVotes[0], 0, "Header votes at index 0 should be 0 (undefined)");
//         assertEq(commandVotes[0], 0, "Command votes at index 0 should be 0 (undefined)");
//     }


//     function test_approveHeader_success() public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         // Add some headers (starting from index 1)
//         $proposal.createHeader("header1");
//         $proposal.createHeader("header2");

//         // Approve a valid header
//         $proposal.approveHeader(1);
//         assertEq($proposal.meta.approvedHeaderId, 1, "Header 1 should be approved");

//         // Try to approve the reserved index 0
//         vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidHeaderId.selector, 0));
//         $proposal.approveHeader(0);
//     }

//     function test_approveHeader_revert_withInvalidHeaderId() public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         // Add some headers
//         for (uint i = 0; i < 3; i++) {
//             $proposal.headers.push();
//         }

//         // Try to approve an invalid header
//         vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidHeaderId.selector, 4));
//         $proposal.approveHeader(4);
//     }

//     function test_approveHeader_success_withRandomHeaderId(uint8 rnd_headerId) public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         // Initialize headers
//         for (uint i = 0; i < MAX_HEADERS; i++) {
//             $proposal.headers.push();
//         }

//         // Bound the headerId
//         rnd_headerId = uint8(bound(rnd_headerId, 1, MAX_HEADERS - 1));

//         $proposal.approveHeader(rnd_headerId);
//         assertEq($proposal.meta.approvedHeaderId, rnd_headerId, "Incorrect header approved");
//     }

//     function test_approveCommand_success() public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         // Add some commands with actions (starting from index 1)
//         for (uint i = 1; i <= 3; i++) {
//             Schema.Action[] memory actions = new Schema.Action[](2);
//             actions[0] = Schema.Action({funcSig: "test1()", abiParams: ""});
//             actions[1] = Schema.Action({funcSig: "test2()", abiParams: ""});
//             $proposal.createCommand(actions);
//         }

//         // Approve a valid command
//         $proposal.approveCommand(1);
//         assertEq($proposal.meta.approvedCommandId, 1, "Command 1 should be approved");

//         // Check if all actions in the approved command are set to Approved
//         for (uint i = 0; i < $proposal.cmds[1].actions.length; i++) {
//             assertEq(uint($proposal.meta.actionStatuses[i]), uint(Schema.ActionStatus.Approved), "Action should be approved");
//         }

//         // Try to approve the reserved index 0
//         vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidCommandId.selector, 0));
//         $proposal.approveCommand(0);
//     }

//     function test_approveCommand_revert_withInvalidCommandId() public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         // Add some commands with actions
//         for (uint i = 0; i < 3; i++) {
//             Schema.Action[] memory actions = new Schema.Action[](2);
//             actions[0] = Schema.Action({funcSig: "test1()", abiParams: ""});
//             actions[1] = Schema.Action({funcSig: "test2()", abiParams: ""});
//             $proposal.createCommand(actions);
//         }

//         // Try to approve an invalid command
//         vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.InvalidCommandId.selector, 4));
//         $proposal.approveCommand(4);
//     }

//     function test_approveCommand_success_withRandomCommandId(uint8 rnd_commandId) public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         // Initialize commands with actions
//         for (uint i = 0; i < MAX_COMMANDS; i++) {
//             Schema.Action[] memory actions = new Schema.Action[](2);
//             actions[0] = Schema.Action({funcSig: "test1()", abiParams: ""});
//             actions[1] = Schema.Action({funcSig: "test2()", abiParams: ""});
//             $proposal.createCommand(actions);
//         }

//         // Bound the commandId
//         rnd_commandId = uint8(bound(rnd_commandId, 1, MAX_COMMANDS - 1));

//         $proposal.approveCommand(rnd_commandId);
//         assertEq($proposal.meta.approvedCommandId, rnd_commandId, "Incorrect command approved");

//         // Check if all actions in the approved command are set to Approved
//         for (uint i = 0; i < $proposal.cmds[rnd_commandId].actions.length; i++) {
//             assertEq(uint($proposal.meta.actionStatuses[i]), uint(Schema.ActionStatus.Approved), "Action should be approved");
//         }
//     }
// }
