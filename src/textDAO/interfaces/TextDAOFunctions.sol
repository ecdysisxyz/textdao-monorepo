// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

interface IInitialize {
    function initialize(Schema.Member[] calldata initialMembers, Schema.DeliberationConfig calldata initialConfig) external;
}

interface IPropose {
    struct ProposeArgs {
        string headerMetadataURI;
        Schema.Action[] actions;
    }
    function propose(ProposeArgs calldata _args) external returns(uint proposalId);
}

interface IFork {
    /**
     * @param pid proposalId
     */
    function fork(uint pid, string calldata headerMetadataURI, Schema.Action[] calldata actions) external;
}

interface IVote {
    function voteHeaders(uint pid, uint[3] calldata headerIds) external;
    function voteCmds(uint pid, uint[3] calldata cmdIds) external;
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
