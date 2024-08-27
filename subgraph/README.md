# TextDAO Subgraph

This subgraph indexes and tracks events from the TextDAO smart contract.

## Project Structure

```
src/
  handlers/           # Event handlers
  utils/              # Utility functions
  types/              # Custom type definitions
  mapping.ts          # Main entry point for The Graph
tests/
  handlers/           # Tests for event handlers
  utils/              # Test utilities
subgraph.yaml         # Subgraph manifest
schema.graphql        # GraphQL schema
```

## Development Guidelines

1. Each event handler should be in its own file under `src/handlers/`.
2. Common utilities should be placed in `src/utils/`.
3. Use custom types defined in `src/types/` for improved type safety.
4. Tests should mirror the structure of the `src/` directory.
5. Always update tests when modifying handler logic.

**All code and tests are written in AssemblyScript. Be mindful of its differences from TypeScript.**

## Running Tests

To run the tests, use the following command:

```
graph test
```
