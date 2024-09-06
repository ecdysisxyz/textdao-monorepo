---
title: "TextDAO Subgraph Test Strategy"
version: 0.1.0
lastUpdated: 2024-09-05
author: TextDAO Development Team
scope: subgraph
type: guide
tags: [subgraph, testing, the graph, matchstick]
relatedDocs: [index.md, coding-standards.md, ../architecture/subgraph-spec.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-05
    description: Initial version of the TextDAO Subgraph Test Strategy
---

# TextDAO Subgraph Test Strategy

This document outlines the testing strategy for the TextDAO subgraph. It covers the types of tests we write, tools we use, and best practices for ensuring the reliability and correctness of our subgraph.

## Testing Framework

We use [Matchstick](https://github.com/LimeChain/matchstick-as), a unit testing framework for subgraph development, to write and run our tests.

## Types of Tests

1. **Unit Tests**: Test individual handler functions in isolation.
2. **Integration Tests**: Test the interaction between multiple entities and handlers.

## Test Structure

Our test files are located in the `tests` directory and follow this naming convention:

```
[entity-name].test.ts
```

Each test file should focus on a specific entity or group of related entities.

## Writing Tests

### Unit Tests

For each handler function, write tests that:

1. Create [mock events](../../tests/utils/mock-events.ts) with various input parameters.
2. Call the handler function with these mock events.
3. Assert that the correct entities are created or updated with the expected values.

Example:

```typescript
import { assert, beforeEach, clearStore, describe, test } from "matchstick-as/assembly/index";
import { handleProposed } from "../../src/event-handlers/proposed";
import { createMockProposedEvent, createMockRepresentativesAssignedEvent } from "../utils/mock-events";

describe("Proposed Event Handler", () => {
  beforeEach(() => {
    clearStore();
  });

  test("Should update existing Proposal entity created by RepresentativesAssigned", () => {
    const pid = BigInt.fromI32(100);
    const proposalEntityId = genProposalId(pid);
    const reps = [Address.fromString("0x1234567890123456789012345678901234567890")];

    // Simulate initial RepresentativesAssigned event
    handleRepresentativesAssigned(createMockRepresentativesAssignedEvent(pid, reps));

    const proposer = Address.fromString("0x0987654321098765432109876543210987654321");
    const createdAt = BigInt.fromI32(1625097600);
    const expirationTime = BigInt.fromI32(1625184000);
    const snapInterval = BigInt.fromI32(72000);

    handleProposed(createMockProposedEvent(pid, proposer, createdAt, expirationTime, snapInterval));

    assert.entityCount("Proposal", 1);
    assert.fieldEquals("Proposal", proposalEntityId, "id", proposalEntityId);
    assert.fieldEquals("Proposal", proposalEntityId, "proposer", proposer.toHexString());
    assert.fieldEquals("Proposal", proposalEntityId, "createdAt", createdAt.toString());
    assert.fieldEquals("Proposal", proposalEntityId, "expirationTime", expirationTime.toString());
  });
});
```

### Integration Tests

Integration tests should:

1. Set up a scenario involving multiple entities and events.
2. Call multiple handler functions in sequence.
3. Assert that the final state of the subgraph is correct.

Example:

```typescript
describe("TextDAO Subgraph Integration Tests", () => {
  test("Creating a proposal and casting votes updates both entities correctly", () => {
    const proposalCreatedEvent = createProposalCreatedEvent("123", "0x1234...", "1631234567")
    handleProposalCreated(proposalCreatedEvent)

    const voteEvent = createVoteEvent("123", "0x5678...", [1, 2, 3], [1, 0, 0])
    handleVoteCast(voteEvent)

    assert.entityCount("Proposal", 1)
    assert.entityCount("Vote", 1)
    assert.fieldEquals("Proposal", "123", "votes", "[0]")
    assert.fieldEquals("Vote", "0", "proposal", "123")
  })
})
```

## Best Practices

1. **Test Coverage**: Aim for high test coverage, especially for critical paths in the subgraph.
2. **Edge Cases**: Include tests for edge cases and potential error scenarios.
3. **Realistic Data**: Use realistic mock data that resembles actual blockchain events.
4. **Isolation**: Ensure each test is isolated and doesn't depend on the state from previous tests.
5. **Performance**: Be mindful of test performance, especially for large datasets.

## Continuous Integration

Integrate subgraph tests into the CI/CD pipeline:

1. Run all tests on every pull request.
2. Block merges if tests fail.
3. Generate and store test coverage reports.

## Manual Testing

In addition to automated tests, perform manual testing:

1. Deploy the subgraph to a test environment.
2. Query the subgraph with various scenarios to ensure correct data retrieval.
3. Verify the subgraph's performance with large datasets.

## Updating Tests

1. Update tests whenever the corresponding handler functions or schema changes.
2. Add new tests for new features or entities added to the subgraph.
3. Refactor tests as needed to maintain clarity and efficiency.

## Troubleshooting

Common testing issues and their solutions:

1. **Failing assertions**: Double-check the expected values and ensure they match the current implementation.
2. **Type mismatches**: Ensure that the types used in tests match those defined in the schema.
3. **Timing issues**: Be aware of block timestamps and ensure they are mocked correctly in tests.

## Resources

- [Matchstick Documentation](https://thegraph.com/docs/en/developer/matchstick/)
- [AssemblyScript Testing Best Practices](https://www.assemblyscript.org/testing.html)
- [The Graph Unit Testing Guide](https://thegraph.com/docs/en/developer/unit-testing-framework/)

By following this test strategy, we can ensure the reliability, correctness, and maintainability of the TextDAO subgraph. Regular review and updates to this strategy will help keep our testing practices aligned with the evolving needs of the project.

## Running Tests

To run the tests for the TextDAO subgraph, we use Matchstick, a unit testing framework for AssemblyScript mappings in The Graph.

### Prerequisites

Before running the tests, ensure you have the following installed:

- Docker: Matchstick requires Docker to run the tests in a controlled environment.

### Running Tests

To execute the tests, run the following command:

```
bun test
```

This command will run all the tests in the `tests` directory.
