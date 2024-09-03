// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title HubDAOErrors
 * @dev Error definitions for HubDAO
 * @custom:version 0.1.0
 */
interface HubDAOErrors {
    // Initialization errors from Initializable @ openzeppelin-contracts~5.0.0
    /// @dev Thrown when initialization is invalid
    error InvalidInitialization();
    /// @dev Thrown when an operation is performed outside of the initializing phase
    error NotInitializing();
}
