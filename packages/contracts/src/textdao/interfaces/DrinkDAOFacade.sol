// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IDrinkDAO} from "bundle/textdao/interfaces/IDrinkDAO.sol";

contract DrinkDAOFacade is IDrinkDAO {
    // TextDAO core functions
    function propose(string calldata headerMetadataCid, Action[] calldata actions) external returns (uint) {}
    function forkCommand(uint pid, Action[] calldata actions) external {}
    function vote(uint pid, Vote calldata repVote) external {}
    function tally(uint _proposalId) external {}
    function tallyAndExecute(uint _proposalId) external {}
    function execute(uint _proposalId) external {}
    // TextDAO protected functions
    function createText(uint256 pid, string memory metadataCid) external returns (uint256 textId) {}
    // TextDAO cheat functions
    function initialize(address admin, DeliberationConfig calldata config) external {}
    function addAdmins(address[] memory newAdmins) external {}
    function addMembers(address[] memory newMembers) external {}
    function addReps(uint pid,address[] memory newMembers) external {}
    function updateConfig(DeliberationConfig calldata newConfig) external {}
    function forceTally(uint pid) external {}
    function getCurrentTopIds(uint pid) external view returns(uint[] memory topHeaderIds, uint[] memory topCommandIds) {}
    function getCurrentScores(uint pid) external view returns(uint[] memory headerScores, uint[] memory commandScores) {}
    function getCurrentTopScores(uint pid) external view returns(uint[] memory topHeaderScores, uint[] memory topCommandScores) {}
    function extendExpirationTime(uint pid, uint timeToExtend) external {}
    function forceApprove(uint pid, uint commandId) external {}
    function forceApproveAndExecute(uint pid, uint commandId) external {}
}
