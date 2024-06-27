// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface TextDAOErrors {
    error ProposalNotFound();
    // Propose
    error HeaderMetadataIsRequired();
    // Tally
    error ProposalNotExpiredYet();
    // Execute
    error ProposalNotApproved();
    error ActionNotFound();
    error NoActionToBeExecuted();
    error ActionExecutionFailed(uint actionId);
    error ProposalAlreadyFullyExecuted();
    // OnlyMember
    error YouAreNotTheMember();
    // OnlyReps
    error YouAreNotTheRep();
    // OnlyVrfCoordinator
    error YouAreNotTheVrfCoordinator();
    // Protection
    error ActionNotApprovedYet();
    error ActionAlreadyExecuted();
    /// @dev From Initializable @ openzeppelin-contracts~5.0.0
    error InvalidInitialization();
    error NotInitializing();
}
