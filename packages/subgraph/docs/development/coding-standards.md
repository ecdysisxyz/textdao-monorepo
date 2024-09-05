---
title: "TextDAO Subgraph Coding Standards"
version: 0.1.0
lastUpdated: 2024-09-05
author: TextDAO Development Team
scope: subgraph
type: guide
tags: [subgraph, coding-standards, best-practices, the graph]
relatedDocs: [index.md, test-strategy.md, ../architecture/subgraph-spec.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-05
    description: Initial version of the TextDAO Subgraph Coding Standards
---

# TextDAO Subgraph Coding Standards

This document outlines the coding standards and best practices for developing the TextDAO subgraph. Adhering to these standards ensures consistency, maintainability, and efficiency in our subgraph development process.

## General Guidelines

1. Use ***AssemblyScript*** for all subgraph development. Be mindful of its differences from TypeScript.
2. Follow the [AssemblyScript style guide](https://www.assemblyscript.org/style-guide.html) for general coding practices.
3. Use meaningful and descriptive names for variables, functions, and entities.
4. Keep functions small and focused on a single responsibility.
5. Comment your code, especially for complex logic or non-obvious implementations.

## Schema Definition

[schema.graphql](../../schema.graphql)

1. Use PascalCase for entity names (e.g., `Proposal`, `Vote`).
2. Use camelCase for field names (e.g., `createdAt`, `approvedHeaderId`).
3. Always specify the type for each field.
4. Use `@entity` decorator for all entities.
5. Use `@derivedFrom` for reverse lookups to avoid redundant data storage.

Example:

```graphql
type Proposal @entity {
  id: ID!
  createdAt: BigInt!
  votes: [Vote!]! @derivedFrom(field: "proposal")
}
```

## Handler Functions

- [Event Handlers](../../src/event-handlers/)
- [File Data Handlers](../../src/file-data-handlers/)

1. Use descriptive names for handler functions that indicate the event being handled.
2. Handle potential null values and use appropriate type checks.
3. Use constants for fixed values like status enums.
4. Implement error handling and logging for unexpected scenarios.

Example:

```typescript
export function handleProposalCreated(event: ProposalCreatedEvent): void {
  let proposal = new Proposal(event.params.proposalId.toString());
  proposal.createdAt = event.block.timestamp;
  proposal.proposer = event.params.proposer;
  proposal.save();

  log.info("Proposal created with ID: {}", [event.params.proposalId.toString()]);
}
```

## Entity Management

1. Always check if an entity exists before trying to load it.
2. Use the `load()` method to retrieve existing entities.
3. Initialize all required fields when creating new entities.
4. Call `save()` after modifying an entity.

Example:

```typescript
const proposal = Proposal.load(proposalId);
if (proposal == null) {
  proposal = new Proposal(proposalId);
  proposal.createdAt = event.block.timestamp;
  // Initialize other fields...
}
// Update fields...
proposal.save();
```

## Type Safety

1. Use strict null checks in AssemblyScript configuration.
2. Explicitly handle null cases when loading entities.
3. Use type assertions judiciously and only when necessary.

## Performance Considerations

1. Minimize the number of entity loads and saves in handler functions.
2. Use derived fields instead of storing redundant data.
3. Be cautious with loops and complex computations in handler functions.

## Testing

1. Write unit tests for all handler functions.
2. Write integration tests for all scenario.
3. Use the mock event function to test event handling.
4. Test edge cases and potential error scenarios.

For more details on testing, refer to the [Test Strategy](test-strategy.md) document.

## Documentation

1. Use JSDoc comments for functions and complex logic.
2. Keep the `README.md` file up-to-date with setup and development instructions.
3. Document any assumptions or important decisions in code comments.

Example:

```typescript
/**
 * Handles the ProposalCreated event.
 * @param event The ProposalCreated event emitted by the contract
 */
export function handleProposalCreated(event: ProposalCreatedEvent): void {
  // Implementation...
}
```

## Version Control

1. Use descriptive commit messages that explain the purpose of the changes.
2. Keep commits focused and atomic.
3. Use feature branches for new developments and bug fixes.

## Continuous Integration

1. Ensure all tests pass before merging changes.
2. Use the Graph CLI for local development and testing.
3. Implement automatic deployment to a test subgraph for pull requests.

By following these coding standards, we ensure that our subgraph codebase remains clean, efficient, and maintainable. Always review and update these standards as our development practices evolve.
