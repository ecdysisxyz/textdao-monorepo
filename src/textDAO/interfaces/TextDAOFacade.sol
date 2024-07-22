// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {Getter} from "bundle/textDAO/functions/Getter.sol";

import {ITextDAO} from "bundle/textDAO/interfaces/ITextDAO.sol";

contract TextDAOFacade is ITextDAO {
    function clone(address _target) external {}
    function initialize(Member[] calldata initialMembers, DeliberationConfig calldata pConfig) external {}
    function propose(string calldata headerMetadataURI, Action[] calldata actions) external returns (uint) {}
    function fork(uint pid, string calldata headerMetadataURI, Action[] calldata actions) external {}
    function vote(uint pid, Vote calldata repVote) external {}
    function voteHeaders(uint _proposalId, uint[3] calldata _headerIds) external {}
    function voteCmds(uint _proposalId, uint[3] calldata _cmdIds) external {}
    function tally(uint _proposalId) external {}
    function execute(uint _proposalId) external {}
    function memberJoin(uint _proposalId, Member[] calldata _candidates) external {}
    function setProposalsConfig(DeliberationConfig calldata _config) external {}
    function overrideProposalsConfig(uint _proposalId, DeliberationConfig calldata _config) external {}
    function saveText(uint _proposalId, string calldata _text) external {}

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
