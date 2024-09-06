// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textdao/storages/Schema.sol";

interface TextDAOEvents {
    // Warnings
    /// @dev Thrown when a given header choice is out of range
    event WARN_HeaderChoiceIsOutOfRange(uint headerChoice);
    /// @dev Thrown when a given command choice is out of range
    event WARN_CommandChoiceIsOutOfRange(uint commandChoice);
    /// @dev Thrown when a given header choice is duplicate
    event WARN_HeaderChoiceIsDuplicate(uint headerChoice);
    /// @dev Thrown when a given command choice is duplicate
    event WARN_CommandChoiceIsDuplicate(uint commandChoice);

    // event
    event DeliberationConfigUpdated(Schema.DeliberationConfig config);
    event DeliberationConfigUpdatedByProposal(uint pid, Schema.DeliberationConfig config);

    // Proposal
    event HeaderCreated(uint pid, uint headerId, string metadataCid);
    event CommandCreated(uint pid, uint commandId, Schema.Action[] actions);

    // Propose
    event Proposed(uint pid, address proposer, uint256 createdAt, uint256 expirationTime, uint256 snapInterval);
    event RepresentativesAssigned(uint pid, address[] reps);
    event VRFRequested(uint pid, uint256 requestId);
    // Vote
    event Voted(uint pid, address rep, Schema.Vote vote);
    // Tally
    event ProposalTalliedWithTie(uint pid, uint epoch, uint[] topHeaderIds, uint[] topCommandIds, uint extendedExpirationTime);
    event ProposalTallied(uint pid, uint approvedHeaderId, uint approvedCommandId);
    event ProposalSnapped(uint pid, uint epoch, uint[] topHeaderIds, uint[] topCommandIds);
    // Execute
    event ProposalExecuted(uint pid, uint approvedCommandId);
    // SaveText
    event TextCreatedByProposal(uint pid, uint textId, string metadataCid);
    event TextUpdatedByProposal(uint pid, uint textId, string newMetadataCid);
    event TextDeletedByProposal(uint pid, uint textId);
    event TextCreated(uint textId, string metadataCid);
    event TextUpdated(uint textId, string newMetadataCid);
    event TextDeleted(uint textId);
    /// @dev From Initializable @ openzeppelin-contracts~5.0.0
    event Initialized(uint64 version);
    // Member
    event MemberAdded(uint memberId, address addr, string metadataCid);
    event MemberUpdated(uint memberId, address addr, string metadataCid);
    event MemberAddedByProposal(uint pid, uint memberId, address addr, string metadataCid);
    event MemberUpdatedByProposal(uint pid, uint memberId, address addr, string metadataCid);
    event MemberRemovedByProposal(uint pid, uint memberId, address addr);
    event MemberRemoved(uint memberId, address addr);
    // Set Config
    // event
}
