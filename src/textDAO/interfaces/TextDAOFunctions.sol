// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

interface IInitialize {
    function initialize(Schema.Member[] calldata initialMembers, Schema.DeliberationConfig calldata initialConfig) external;
}

interface IPropose {
    function propose(string calldata headerMetadataURI, Schema.Action[] calldata actions) external returns(uint proposalId);
}

interface IFork {
    /**
     * @param pid proposalId
     */
    function fork(uint pid, string calldata headerMetadataURI, Schema.Action[] calldata actions) external;
}

interface IVote {
    function vote(uint pid, Schema.Vote calldata repVote) external;
}

interface ITally {
    function tally(uint pid) external;
}

interface IExecute {
    function execute(uint pid) external;
}

interface TextDAOFunctions is
    IInitialize,
    IPropose,
    IFork,
    IVote,
    ITally,
    IExecute
{}
