// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

interface IClone {
    function clone(bytes calldata initData) external returns(address proxy);
}

interface IInitialize {
    function initialize(Schema.Member[] calldata initialMembers, Schema.DeliberationConfig calldata initialConfig) external;
}

interface IPropose {
    function propose(string calldata headerMetadataCid, Schema.Action[] calldata actions) external returns(uint proposalId);
}

interface IFork {
    /**
     * @param pid proposalId
     */
    function fork(uint pid, string calldata headerMetadataCid, Schema.Action[] calldata actions) external;
}

interface IVote {
    function vote(uint pid, Schema.Vote calldata repVote) external;
}

interface ITally {
    function tally(uint pid) external;
    function tallyAndExecute(uint pid) external;
}

interface IExecute {
    function execute(uint pid) external;
}

interface ISaveText {
    function createText(uint256 pid, string memory metadataCid) external returns (uint256 textId);
    function updateText(uint256 pid, uint256 textId, string memory newMetadataCid) external;
    function deleteText(uint256 pid, uint256 textId) external;
}
interface ITextManagement {
    function createText(uint256 pid, string memory metadataCid) external returns (uint256 textId);
    function updateText(uint256 pid, uint256 textId, string memory newMetadataCid) external;
    function deleteText(uint256 pid, uint256 textId) external;
}

interface IMemberJoin {
    function memberJoin(uint pid, Schema.Member[] memory candidates) external;
}

interface IMembershipManagement {
    function addMembers(uint pid, Schema.Member[] memory candidates) external;
    function updateMember(uint memberId, string memory newMetadataURI) external;
    function removeMember(uint pid, uint memberId) external;
    function leaveDAO(uint memberId) external;
}

interface ISetConfigs {
    function setDebelirationConfig(uint pid, Schema.DeliberationConfig calldata config) external;
}
interface IConfigManagement {
    function setDebelirationConfig(uint pid, Schema.DeliberationConfig calldata config) external;
}

interface TextDAOMainFunctions is
    IClone,
    IInitialize,
    IPropose,
    IFork,
    IVote,
    ITally,
    IExecute
{}

interface TextDAOProtectedFunctions is
    IMembershipManagement,
    ITextManagement,
    IConfigManagement
{}
