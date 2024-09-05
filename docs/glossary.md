---
title: "TextDAO Glossary"
version: 0.1.0
lastUpdated: 2024-09-04
author: TextDAO Development Team
scope: project
type: reference
tags: [glossary, terminology, definitions]
relatedDocs: [../README.md, project-structure.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-04
    description: Initial version of the glossary
---

# TextDAO Glossary

This glossary provides definitions for key terms used throughout the TextDAO project.

## A

### Action
A specific operation to be performed as part of a Command. It includes a function signature and ABI-encoded parameters.

### ActionStatus
An enumeration representing the current state of an Action: Proposed, Approved, or Executed.

## C

### Command
A group of Actions. Commands are part of a Proposal and can be voted on separately.

## D

### Deliberation
The core functionality of TextDAO, containing the process of propose, fork, vote, tally and execute.

### Deliberation (contract schema struct)
The core structure of TextDAO, containing an array of Proposals and configuration settings for the deliberation process.

### DeliberationConfig
Configuration settings for the deliberation process, including expiry duration, snapshot interval, number of representatives, and quorum score.

## H

### Header
Part of a Proposal, containing title and body.

### HubDAO
The central contract that manages multiple TextDAO instances.

## M

### MC (Meta Contract)
A library utilized by TextDAO that implements the UCS architecture. It provides the foundation for TextDAO's upgradeable and scalable design.

### MC DevKit
A development toolkit used in TextDAO for enhanced contract development and testing. It extends forge-std and implements features like State Fuzzing and UCS architecture.

### Member
An individual participant in the TextDAO, represented by an address and associated metadata.

## P

### Proposal
A core concept in TextDAO, consisting of Headers, Commands, and metadata. Proposals are subject to deliberation and voting.

### ProposalMeta
Metadata associated with a Proposal, including information about representatives, votes, and the current state of the proposal.

## R

### Representative (Rep)
A member of the DAO who has the right to fork and vote on proposals. Also referred to as "rep" in the code.

## S

### Schema
Defines the data structures used in TextDAO, including structures for Deliberation, Proposal, Text, Member, etc. These structures are utilized by the MC library for shared access across functions.

## T

### Text
A core entity in TextDAO, representing a piece of content with associated metadata.

### TextDAO
The main contract implementing the decentralized autonomous organization for collaborative text management.

## U

### UCS (Upgradeable Clone for Scalable Contracts)
An architecture implemented by MC and utilized in TextDAO to provide function-level upgradeability and factory/clone-friendly features.

## V

### Vote
A structure representing a member's vote on a Proposal, including ranked choices for Headers and Commands.

### VRF (Verifiable Random Function)
A cryptographic primitive used in TextDAO, likely for random selection processes or to introduce unpredictability in certain DAO operations.
