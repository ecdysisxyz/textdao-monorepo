// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface TextDAOErrors {
    // Propose
    error HeaderMetadataIsRequired();
    // Tally
    error ProposalNotExpiredYet();
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
