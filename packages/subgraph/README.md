---
title: "TextDAO Subgraph"
version: 0.1.0
lastUpdated: 2024-09-05
author: TextDAO Development Team
scope: subgraph
type: readme
tags: [subgraph, graphql, the graph, ethereum]
relatedDocs: [architecture/index.md, development/index.md, guides/index.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-05
    description: Initial version of the TextDAO Subgraph README
---

# TextDAO Subgraph

This subgraph indexes and tracks events from the TextDAO & HubDAO smart contracts, providing efficient querying capabilities for the TextDAO application.

## Overview

The TextDAO subgraph is built using The Graph protocol, allowing for efficient indexing and querying of blockchain data. It tracks events emitted by TextDAO smart contracts and organizes the data into easily queryable entities.

## Key Features

- Indexes TextDAO contract events
  - ***HubDAO***: A factory for TextDAO instances
  - ***TextDAOs***
- Indexes the IPFS contents related with TextDAO
- Provides GraphQL API for querying HubDAO & TextDAO data

## Project Structure

```
subgraph/
├── src/
│   ├──event-handlers
│   │   └── [contract event handlers (e.g. command-created.ts)]
│   ├──file-data-handlers
│   │   └── [file data source template handlers (e.g. text-contents.ts)]
│   ├──utils
│   │   │── entity-id-provider.ts
│   │   │── entity-provider.ts
│   │   │── schema-types.ts
│   │   └── type-formatter.ts
│   └── mapping.ts
├── tests/
│   ├──handlers
│   │   └── [handler unit tests (e.g. command-created.test.ts)]
│   ├──utils
│   │   ├──ipfs-file-data
│   │   │   └── [ipfs file fixtures (e.g. sample-text-metadata1.json)]
│   │   │── mock-entities.ts
│   │   └── mock-events.ts
│   └── textdao-handlers.integration.test.ts
├── subgraph.yaml
├── schema.graphql
├── matchstick.yaml
└── package.json
```

## Documentation

For more detailed information, please refer to the following documentation:

- [Architecture Overview](docs/architecture/index.md)
- [Development Guide](docs/development/index.md)
- [Usage Guide](docs/guides/index.md)

## Contributing

Contributions to the TextDAO subgraph are welcome. Please refer to the [CONTRIBUTING.md](../../CONTRIBUTING.md) file in the root of the monorepo for guidelines.

## License

This project is licensed under the [MIT License](LICENSE).
