// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TextDAO Schema v0.1.0
 */
interface Schema {
    /// @custom:storage-location erc7201:textDAO.Deliberation
    struct Deliberation {
        Proposal[] proposals;
        DeliberationConfig config;
    }
    struct DeliberationConfig {
        uint expiryDuration;
        uint snapInterval;
        uint repsNum;
        uint quorumScore;
    }
    struct Proposal {
        Header[] headers;
        Command[] cmds;
        ProposalMeta meta;
    }
    struct Header {
        uint currentScore;
        string metadataURI;
        uint[] tagIds;
    }
    struct Command {
        Action[] actions;
        uint currentScore;
    }
    struct Action {
        string funcSig;
        bytes abiParams;
    }
    enum ActionStatus {
        Proposed,
        Approved,
        Executed
    }
    struct ProposalMeta {
        address[] reps;
        mapping(address rep => Vote) votes;
        uint[] headerScores;
        uint[] commandScores;
        uint approvedHeaderId;
        uint approvedCommandId;
        mapping(uint actionId => ActionStatus) actionStatuses;
        bool fullyExecuted;
        uint expirationTime;
        uint vrfRequestId;
        uint snapInterval;
        mapping(uint epoch => bool) snapped;
        uint createdAt;
    }
    struct Vote {
        uint[3] rankedHeaderIds;
        uint[3] rankedCommandIds;
    }


    /// @custom:storage-location erc7201:textDAO.Texts
    struct Texts {
        Text[] texts;
    }
    struct Text {
        string metadataURI;
    }


    /// @custom:storage-location erc7201:textDAO.Members
    struct Members {
        Member[] members;
    }
    struct Member {
        address addr;
        string metadataURI;
    }


    /// @custom:storage-location erc7201:textDAO.VRFStorage
    struct VRFStorage {
        mapping(uint requestId => VRFRequest) requests;
        uint64 subscriptionId;
        VRFConfig config;
    }
    struct VRFRequest {
        uint proposalId;
        uint256[] randomWords;
    }
    struct VRFConfig {
        address vrfCoordinator;
        bytes32 keyHash;
        uint32 callbackGasLimit;
        uint16 requestConfirmations;
        uint32 numWords;
        address LINKTOKEN;
    }

    /// @custom:storage-location erc7201:textDAO.ConfigOverrideStorage
    struct ConfigOverrideStorage {
        mapping(bytes4 => ConfigOverride) overrides;
        // bytes4[] overridesIndex;
    }
    struct ConfigOverride {
        uint quorumScore;
    }


    /// @custom:storage-location erc7201:textDAO.TagStorage
    struct TagStorage {
        mapping(uint => Tag) tags;
        uint nextId;
    }
    struct Tag {
        uint id;
        bytes32 metadataURI;
    }

    /// @custom:storage-location erc7201:textDAO.TagRelationStorage
    struct TagRelationStorage {
        mapping(uint => TagRelation) relations;
        uint nextId;
    }
    struct TagRelation {
        uint id;
        uint tagId;
        uint taggedId;
    }


    /**
     * @dev Initializable @openzeppelin~5.0.0
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

}


