// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

// /**
//  * @title RankLib
//  * @dev Library for implementing Ranked Choice Voting (RCV) algorithms
//  * @notice This library provides functions to find top ranked choices in an array of votes
//  * @custom:version 0.1.0
//  */
// library RankLib {
//     /**
//      * @notice Finds the indices of the highest scoring option(s)
//      * @param _scores Array of scores
//      * @return topIndices Array of indices with the highest score
//      * @custom:throws TextDAOErrors.VotesArrayIsEmpty() if the input array is empty
//      */
//     function findTopScorer(uint[] memory _scores) internal pure returns(uint[] memory topIndices) {
//         if (_scores.length == 0) revert TextDAOErrors.VotesArrayIsEmpty();

//         uint maxVote = _scores[0];
//         uint count = 1;
//         uint[] memory indices = new uint[](_scores.length);
//         indices[0] = 0;

//         for (uint i = 1; i < _scores.length; ++i) {
//             if (_scores[i] > maxVote) {
//                 maxVote = _scores[i];
//                 count = 1;
//                 indices[0] = i;
//             } else if (_scores[i] == maxVote) {
//                 indices[count] = i;
//                 count++;
//             }
//         }

//         topIndices = new uint[](count);
//         for (uint i = 0; i < count; i++) {
//             topIndices[i] = indices[i];
//         }

//         return topIndices;
//     }

//     /**
//      * @notice Finds the indices of the top 3 highest scoring options
//      * @param _scores Array of scores
//      * @return top3Indices Array of indices with the top 3 highest scores
//      * @custom:throws TextDAOErrors.VotesArrayIsEmpty() if the input array is empty
//      */
//     function findTop3Scorers(uint[] memory _scores) internal pure returns(uint[] memory top3Indices) {
//         if (_scores.length == 0) revert TextDAOErrors.VotesArrayIsEmpty();

//         uint[3] memory topVotes = [uint(0), 0, 0];
//         uint[3] memory topIndices = [type(uint).max, type(uint).max, type(uint).max];
//         uint count = 0;
//         bool allZero = true;

//         for (uint i = 0; i < _scores.length; ++i) {
//             if (_scores[i] > 0) allZero = false;
//             if (_scores[i] > topVotes[2]) {
//                 if (_scores[i] > topVotes[1]) {
//                     if (_scores[i] > topVotes[0]) {
//                         topVotes[2] = topVotes[1];
//                         topIndices[2] = topIndices[1];
//                         topVotes[1] = topVotes[0];
//                         topIndices[1] = topIndices[0];
//                         topVotes[0] = _scores[i];
//                         topIndices[0] = i;
//                     } else {
//                         topVotes[2] = topVotes[1];
//                         topIndices[2] = topIndices[1];
//                         topVotes[1] = _scores[i];
//                         topIndices[1] = i;
//                     }
//                 } else {
//                     topVotes[2] = _scores[i];
//                     topIndices[2] = i;
//                 }
//                 if (count < 3) count++;
//             }
//         }

//         if (allZero) {
//             top3Indices = new uint[](_scores.length);
//             for (uint i = 0; i < _scores.length; ++i) {
//                 top3Indices[i] = i;
//             }
//         } else {
//             top3Indices = new uint[](count);
//             for (uint i = 0; i < count; ++i) {
//                 top3Indices[i] = topIndices[i];
//             }
//         }

//         return top3Indices;
//     }
// }


// /// Testing
// import {Test} from "@devkit/Flattened.sol";

// /**
//  * @title RankLibTest
//  * @dev Test contract for the RankLib library
//  */
// contract RankLibTest is Test {
//     using RankLib for uint[];

//     /**
//      * @notice Tests finding the top scorer with a single maximum value
//      */
//     function test_findTopScorer_singleMax() public pure {
//         uint[] memory scores = new uint[](5);
//         scores[0] = 10;
//         scores[1] = 5;
//         scores[2] = 15;
//         scores[3] = 8;
//         scores[4] = 12;

//         uint[] memory result = scores.findTopScorer();
//         assertEq(result.length, 1, "Should find only one top scorer");
//         assertEq(result[0], 2, "Should find index 2 as the top scorer");
//     }

//     /**
//      * @notice Tests finding the top scorer with multiple maximum values
//      */
//     function test_findTopScorer_multipleMax() public {
//         uint[] memory scores = new uint[](5);
//         scores[0] = 15;
//         scores[1] = 10;
//         scores[2] = 15;
//         scores[3] = 8;
//         scores[4] = 15;

//         uint[] memory result = scores.findTopScorer();
//         assertEq(result.length, 3, "Should find three top scorers");
//         assertEq(result[0], 0, "First top scorer should be index 0");
//         assertEq(result[1], 2, "Second top scorer should be index 2");
//         assertEq(result[2], 4, "Third top scorer should be index 4");
//     }

//     /**
//      * @notice Test findTopScorer with an empty array
//      */
//     function test_findTopScorer_EmptyArray() public {
//         uint[] memory scores = new uint[](0);

//         vm.expectRevert(TextDAOErrors.VotesArrayIsEmpty.selector);
//         scores.findTopScorer();
//     }

//     /**
//      * @notice Tests finding the top 3 scorers with distinct values
//      */
//     function test_findTop3Scorers_distinctValues() public {
//         uint[] memory scores = new uint[](5);
//         scores[0] = 10;
//         scores[1] = 5;
//         scores[2] = 15;
//         scores[3] = 8;
//         scores[4] = 12;

//         uint[] memory result = scores.findTop3Scorers();
//         assertEq(result.length, 3, "Should find three top scorers");
//         assertEq(result[0], 2, "First top scorer should be index 2");
//         assertEq(result[1], 4, "Second top scorer should be index 4");
//         assertEq(result[2], 0, "Third top scorer should be index 0");
//     }

//     /**
//      * @notice Tests finding the top 3 scorers with tied values
//      */
//     function test_findTop3Scorers_tiedValues() public {
//         uint[] memory scores = new uint[](5);
//         scores[0] = 15;
//         scores[1] = 10;
//         scores[2] = 15;
//         scores[3] = 10;
//         scores[4] = 15;

//         uint[] memory result = scores.findTop3Scorers();
//         assertEq(result.length, 3, "Should find three top scorers");
//         assertEq(result[0], 0, "First top scorer should be index 0");
//         assertEq(result[1], 2, "Second top scorer should be index 2");
//         assertEq(result[2], 4, "Third top scorer should be index 4");
//     }

//     /**
//      * @notice Test findTop3Scorer with less than three values
//      */
//     function test_findTop3Scorer_LessThanThreeValues() public pure {
//         uint[] memory votes = new uint[](2);
//         votes[0] = 10;
//         votes[1] = 5;

//         uint[] memory result = votes.findTop3Scorer();
//         assertEq(result.length, 2, "Should find two top indices");
//         assertEq(result[0], 0, "First top index should be 0");
//         assertEq(result[1], 1, "Second top index should be 1");
//     }

//     /**
//      * @notice Test findTop3Scorer with an empty array
//      */
//     function test_findTop3Scorer_EmptyArray() public {
//         uint[] memory votes = new uint[](0);

//         vm.expectRevert(TextDAOErrors.VotesArrayIsEmpty.selector);
//         votes.findTop3Scorer();
//     }

//     /**
//      * @notice Test findTop1 with all zero values
//      */
//     function test_findTop1_AllZeros() public pure {
//         uint[] memory votes = new uint[](5);
//         // All values are 0 by default

//         uint[] memory result = votes.findTop1();
//         assertEq(result.length, 5, "Should find all indices as top");
//         for (uint i = 0; i < 5; i++) {
//             assertEq(result[i], i, "Should include all indices");
//         }
//     }

//     /**
//      * @notice Test findTop3Scorer with all zero values
//      */
//     function test_findTop3Scorer_AllZeros() public pure {
//         uint[] memory votes = new uint[](5);
//         // All values are 0 by default

//         uint[] memory result = votes.findTop3Scorer();
//         assertEq(result.length, 5, "Should find all indices as top");
//         for (uint i = 0; i < 5; i++) {
//             assertEq(result[i], i, "Should include all indices");
//         }
//     }

//     /**
//      * @notice Test gas consumption of findTop1 with various array sizes
//      */
//     function test_GasConsumption_findTop1() public view {
//         uint[] memory smallArray = new uint[](10);
//         uint[] memory mediumArray = new uint[](100);
//         uint[] memory largeArray = new uint[](1000);

//         for (uint i = 0; i < 10; i++) smallArray[i] = i;
//         for (uint i = 0; i < 100; i++) mediumArray[i] = i;
//         for (uint i = 0; i < 1000; i++) largeArray[i] = i;

//         uint gasStart;
//         uint gasUsed;

//         // Test small array
//         gasStart = gasleft();
//         smallArray.findTop1();
//         gasUsed = gasStart - gasleft();
//         assertLt(gasUsed, 5000, "Gas usage for small array should be less than 5000");

//         // Test medium array
//         gasStart = gasleft();
//         mediumArray.findTop1();
//         gasUsed = gasStart - gasleft();
//         assertLt(gasUsed, 30000, "Gas usage for medium array should be less than 30000");

//         // Test large array
//         gasStart = gasleft();
//         largeArray.findTop1();
//         gasUsed = gasStart - gasleft();
//         assertLt(gasUsed, 300000, "Gas usage for large array should be less than 300000");
//     }

//     /**
//      * @notice Test gas consumption of findTop3Scorer with various array sizes
//      */
//     function test_GasConsumption_findTop3Scorer() public view {
//         uint[] memory smallArray = new uint[](10);
//         uint[] memory mediumArray = new uint[](100);
//         uint[] memory largeArray = new uint[](1000);

//         for (uint i = 0; i < 10; i++) smallArray[i] = i;
//         for (uint i = 0; i < 100; i++) mediumArray[i] = i;
//         for (uint i = 0; i < 1000; i++) largeArray[i] = i;

//         uint gasStart;
//         uint gasUsed;

//         // Test small array
//         gasStart = gasleft();
//         smallArray.findTop3Scorer();
//         gasUsed = gasStart - gasleft();
//         assertLt(gasUsed, 10000, "Gas usage for small array should be less than 10000");

//         // Test medium array
//         gasStart = gasleft();
//         mediumArray.findTop3Scorer();
//         gasUsed = gasStart - gasleft();
//         assertLt(gasUsed, 70000, "Gas usage for medium array should be less than 70000");

//         // Test large array
//         gasStart = gasleft();
//         largeArray.findTop3Scorer();
//         gasUsed = gasStart - gasleft();
//         assertLt(gasUsed, 660000, "Gas usage for large array should be less than 550000");
//     }
// }
