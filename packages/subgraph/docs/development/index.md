---
title: "TextDAO Subgraph Development Guide"
version: 0.1.0
lastUpdated: 2024-09-05
author: TextDAO Development Team
scope: subgraph
type: guide
tags: [subgraph, development, the graph, graphql]
relatedDocs: [coding-standards.md, test-strategy.md, ../architecture/index.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-05
    description: Initial version of the TextDAO Subgraph Development Guide
---

# TextDAO Subgraph Development Guide

This guide provides essential information for developers working on the TextDAO subgraph. It covers setup, development workflow, testing, and deployment processes.

## Development Environment Setup

### Prerequisites

- node.js: version 18 or later
- Docker: Latest stable version (required for running tests)

### Setup flow

1. Clone the TextDAO monorepo and navigate to the subgraph package:
   ```
   git clone git@github.com:ecdysisxyz/textdao-monorepo.git
   cd textdao-monorepo/packages/subgraph
   ```
2. Install dependencies:
   ```
   bun install
   ```

3. Generate types:
   ```
   bun codegen
   ```

4. Build the subgraph:
   ```
   bun run build
   ```

5. Test the subgraph with matchstick-as (ensure Docker is running):
   ```
   bun run test
   ```

6. Deploy the subgraph (replace `<subgraph-name>` and `version-label` with your actual value):
   ```
   bun deploy <subgraph-name> -l <version-label>
   ```

## Development Workflow

1. Update the schema in `schema.graphql` if new entities or fields are required.
2. Modify or create handler files in the `src/event-handlers/` or `src/file-data-handlers/` directory to handle events and update entities.
3. Update the `subgraph.yaml` file if new data sources or event handlers are added.
4. Generate AssemblyScript types:
   ```
   bun codegen
   ```
5. Build the subgraph:
   ```
   bun run build
   ```
6. Run tests (see [Test Strategy](test-strategy.md) for more details):
   ```
   bun test
   ```

## Coding Standards

**All code and tests are written in AssemblyScript. Be mindful of its differences from TypeScript.**

Please refer to the [Coding Standards](coding-standards.md) document for detailed guidelines on code style, best practices, and conventions specific to subgraph development.

## Testing

Comprehensive testing is crucial for maintaining the reliability and accuracy of the subgraph. See the [Test Strategy](test-strategy.md) document for information on writing and running tests.

## Deployment

To deploy the subgraph to The Graph's hosted service:

1. Authenticate with The Graph:
   ```
   graph auth https://api.thegraph.com/deploy/ <your-access-token>
   ```
2. Deploy the subgraph:
   ```
   bun deploy <subgraph-name> -l <version-label>
   ```

For detailed deployment instructions and environment-specific configurations, please refer to the deployment guide (coming soon).

## Troubleshooting

Common issues and their solutions:

1. **Handler compilation errors**: Ensure all imported modules are correctly referenced and AssemblyScript types are properly used.
2. **Subgraph indexing failures**: Check the subgraph logs for specific error messages. Common causes include incorrect ABI definitions or mismatched event signatures.
3. **Query performance issues**: Review entity relationships and consider adding derived fields or denormalized data for frequently accessed information.

## Contributing

Contributions to the TextDAO subgraph are welcome. Please follow these steps:

1. Fork the repository and create a new branch for your feature or bug fix.
2. Make your changes, ensuring they adhere to the coding standards.
3. Write or update tests as necessary.
4. Submit a pull request with a clear description of your changes.

For more detailed contribution guidelines, please refer to the [CONTRIBUTING.md](../../../../CONTRIBUTING.md) file in the root of the monorepo.

## Additional Resources

- [The Graph Documentation](https://thegraph.com/docs/)
- [AssemblyScript Documentation](https://www.assemblyscript.org/introduction.html)
- [GraphQL Specification](https://spec.graphql.org/)

If you encounter any issues or have questions not covered in this guide, please reach out to the TextDAO development team or [open an issue](https://github.com/ecdysisxyz/textdao-monorepo/issues) in the repository.
