// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {Getter} from "bundle/textdao/functions/Getter.sol";

import {ITextDAO} from "bundle/textdao/interfaces/ITextDAO.sol";

contract TextDAOFacade is ITextDAO {
    // TextDAO core functions
    function clone(bytes calldata initData) external returns(address proxy) {}
    function initialize(Member[] calldata initialMembers, DeliberationConfig calldata pConfig) external {}
    function propose(string calldata headerMetadataCid, Action[] calldata actions) external returns (uint) {}
    function fork(uint pid, string calldata headerMetadataCid, Action[] calldata actions) external {}
    function forkHeader(uint pid, string calldata headerMetadataCid) external {}
    function forkCommand(uint pid, Action[] calldata actions) external {}
    function vote(uint pid, Vote calldata repVote) external {}
    function tally(uint _proposalId) external {}
    function tallyAndExecute(uint _proposalId) external {}
    function execute(uint _proposalId) external {}
    // TextDAO protected functions
    function memberJoin(uint _proposalId, Member[] calldata _candidates) external {}
    function createText(uint256 pid, string memory metadataCid) external returns (uint256 textId) {}
    function updateText(uint256 pid, uint256 textId, string memory newMetadataCid) external {}
    function deleteText(uint256 pid, uint256 textId) external {}
    function setDebelirationConfig(uint pid, DeliberationConfig calldata config) external {}
    // function overrideProposalsConfig(uint _proposalId, DeliberationConfig calldata _config) external {}
}

contract TextDAOWithCheatsFacade is TextDAOFacade {
    function addAdmin(address[] memory newAdmins) external {}
    function addMembers(address[] memory newMembers) external {}
    function updateConfig(DeliberationConfig calldata newConfig) external {}
    function transferAdmin(address newAdmin) external {}
    function forceTally(uint pid) external {}
    function forceApprove(uint pid, uint commandId) external {}
    function forceApproveAndExecute(uint pid, uint commandId) external {}
    // function forceApprove(uint pid, uint headerId, uint commandId) external {}
    // function forceApproveAndExecute(uint pid, uint headerId, uint commandId) external {}
}

contract TextDAOWithGetterFacade is TextDAOFacade {
    // Getters
    // function getProposal(uint id) external view returns (Getter.ProposalInfo memory) {}
    // function getProposalHeaders(uint id) external view returns (Header[] memory) {}
    // // function getProposalCommand(uint pid, uint cid) external view returns (Command memory) {}
    // function getProposalsConfig() external view returns (DeliberationConfig memory) {}
    // function getText(uint id) external view returns (Text memory) {}
    // function getTexts() external view returns (Text[] memory) {}
    // function getMember(uint id) external view returns (Member memory) {}
    // function getMembers() external view returns (Member[] memory) {}
    // function getSubscriptionId() external view returns (uint64) {}
    // function getVRFConfig() external view returns (VRFConfig memory) {}
    // function getConfigOverride(bytes4 sig) external view returns (ConfigOverride memory) {}
}
