---
title: "TextDAO Subgraph Specification"
version: 0.1.0
lastUpdated: 2024-09-05
author: TextDAO Development Team
scope: subgraph
type: specification
tags: [subgraph, specification, the graph, graphql, schema]
relatedDocs: [index.md, ../development/coding-standards.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-05
    description: Initial version of the TextDAO Subgraph Specification
---

# TextDAO Subgraph Specification

This document provides a detailed specification of the TextDAO subgraph, including its schema, entities, and relationships.

## Schema Overview

The [TextDAO subgraph schema](../../schema.graphql) defines the structure of the data that is indexed from the TextDAO smart contracts. The main entities in the schema are:

- Proposal
- Vote
- Member
- Text
- DeliberationConfig

## Entities

- ***Proposal***: Represents a proposal in the TextDAO system.
    - ***Header***: Represents a proposal header.
    - ***Command***: Represents a proposal command.
        - ***Action***: Represents an action within a command.
    - ***Vote***: Represents a vote cast on a proposal.
- ***Member***: Represents a member of the TextDAO.
- ***Text***: Represents a text document in the TextDAO system.
- ***DeliberationConfig***: Represents the configuration for the deliberation process.

## Relationships

- A `Proposal` has many `Header`s, `Command`s, and `Vote`s.
- A `Command` has many `Action`s.
- A `Vote` belongs to a `Proposal` and a `Member`.

## Indexing Strategy

The subgraph indexes the following events from the TextDAO smart contracts:

- `DeliberationConfigUpdated((uint256,uint256,uint256,uint256))`
- `DeliberationConfigUpdatedByProposal(uint256,(uint256,uint256,uint256,uint256))`
- `CommandCreated(uint256,uint256,(string,bytes)[])`
- `HeaderCreated(uint256,uint256,string)`
- `ProposalExecuted(uint256,uint256)`
- `ProposalSnapped(uint256,uint256,uint256[],uint256[])`
- `ProposalTallied(uint256,uint256,uint256)`
- `ProposalTalliedWithTie(uint256,uint256,uint256[],uint256[],uint256)`
- `Proposed(uint256,address,uint256,uint256,uint256)`
- `RepresentativesAssigned(uint256,address[])`
- `TextCreated(uint256,string)`
- `TextUpdated(uint256,string)`
- `TextDeleted(uint256)`
- `TextCreatedByProposal(uint256,uint256,string)`
- `TextUpdatedByProposal(uint256,uint256,string)`
- `TextDeletedByProposal(uint256,uint256)`
- `Voted(uint256,address,(uint256[3],uint256[3]))`
- `VRFRequested(uint256,uint256)`
- `MemberAdded(uint256,address,string)`
- `MemberUpdated(uint256,address,string)`
- `MemberAddedByProposal(uint256,uint256,address,string)`
- `MemberUpdatedByProposal(uint256,uint256,address,string)`

Each event is processed by a corresponding handler function that updates the relevant entities in the subgraph.

## Query Examples

Here are some example queries that can be performed on this subgraph:

1. Fetch recent proposals with their headers and commands:

```graphql
query RecentProposals {
  proposals(first: 10, orderBy: createdAt, orderDirection: desc) {
    id
    proposer
    createdAt
    headers {
      title
      body
    }
    commands {
      actions {
        func
        status
      }
    }
  }
}
```

2. Get votes for a specific proposal:

```graphql
query ProposalVotes($proposalId: ID!) {
  proposal(id: $proposalId) {
    votes {
      voter
      rankedHeaderIds
      rankedCommandIds
    }
  }
}
```

3. Fetch member details:

```graphql
query MemberDetails($memberId: ID!) {
  member(id: $memberId) {
    addr
    name
    image
    bio
  }
}
```

## Future Considerations

- Implementing more complex aggregations for proposal statistics.
- Adding support for tagging and categorizing proposals.
- Enhancing the member entity with participation metrics.

For implementation details and best practices, please refer to the [Coding Standards](../development/coding-standards.md) document.
