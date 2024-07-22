// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TextDAOErrors
 * @dev Error definitions for TextDAO
 * @custom:version 0.1.0
 */
interface TextDAOErrors {
    // General errors
    /// @dev Thrown when a proposal is not found
    error ProposalNotFound();
    /// @dev Thrown when a given votes array is empty
    error VotesArrayIsEmpty();
    /// @dev Thrown when a given header choice is out of range
    error HeaderChoiceIsOutOfRange(uint choice);

    // Propose errors
    /// @dev Thrown when header metadata is missing
    error HeaderMetadataIsRequired();

    // VRF Request errors
    error InvalidVRFSubscription();
    error InvalidVRFCoordinator();
    error InvalidVRFKeyHash();
    error InvalidVRFCallbackGasLimit();
    error InvalidVRFRequestConfirmations();
    error InvalidVRFNumWords();
    error InvalidVRFLinkToken();

    // Vote errors
    /// @dev Thrown when the proposal has already expired
    error ProposalAlreadyExpired();

    // Tally errors
    /// @dev Thrown when trying to tally a proposal that hasn't expired yet
    error ProposalNotExpiredYet();
    error AlreadySnapped();
    error ProposalAlreadyApproved();

    // Execute errors
    /// @dev Thrown when trying to execute an unapproved proposal
    error ProposalNotApproved();
    /// @dev Thrown when an action is not found
    error ActionNotFound();
    /// @dev Thrown when there are no actions to execute
    error NoActionToBeExecuted();
    /// @dev Thrown when an action execution fails
    error ActionExecutionFailed(uint actionId);
    /// @dev Thrown when trying to execute an already fully executed proposal
    error ProposalAlreadyFullyExecuted();

    // Access control errors
    /// @dev Thrown when a non-member tries to perform a member-only action
    error YouAreNotTheMember();
    /// @dev Thrown when a non-representative tries to perform a representative-only action
    error YouAreNotTheRep();
    /// @dev Thrown when a non-VRF coordinator tries to perform a VRF coordinator-only action
    error YouAreNotTheVrfCoordinator();

    // Protection errors
    /// @dev Thrown when trying to execute an unapproved action
    error ActionNotApprovedYet();
    /// @dev Thrown when trying to execute an already executed action
    error ActionAlreadyExecuted();

    // Initialization errors from Initializable @ openzeppelin-contracts~5.0.0
    /// @dev Thrown when initialization is invalid
    error InvalidInitialization();
    /// @dev Thrown when an operation is performed outside of the initializing phase
    error NotInitializing();

    // ProposalLib errors
    /// @dev Thrown when an invalid header ID is provided
    error InvalidHeaderId(uint headerId);
    /// @dev Thrown when an invalid command ID is provided
    error InvalidCommandId(uint commandId);

    // DaveText
    error TextMetadataURIIsRequired();
    error TextNotFound(uint textId);
}
