---
title: "TextDAO Contracts Package"
version: 0.1.0
lastUpdated: 2024-09-04
author: TextDAO Development Team
scope: contracts
type: readme
tags: [smart-contracts, solidity, ethereum, textdao]
relatedDocs: [
  "docs/architecture/index.md",
  "docs/guides/index.md",
  "docs/development/index.md"
]
changeLog:
  - version: 0.1.0
    date: 2024-09-04
    description: Initial version of the contracts package README
---

# TextDAO Contracts

This package contains the smart contracts for the TextDAO project, including the HubDAO and TextDAO contracts.

## Overview

TextDAO is a decentralized autonomous organization (DAO) focused on collaborative text creation and management. The smart contracts in this package form the core of the TextDAO ecosystem, enabling governance, proposal management, and text operations.

## Motivation
- No more google docs for DAOs.
- Any groupware would be acceptable for daily discourse.
- But decision making over treasury and law must be on this DAO.

## Key Components

- **HubDAO**: The central contract that manages the creation and interaction of individual TextDAOs.
- **TextDAO**: The core contract for each individual DAO instance, handling proposals, voting, and text management.
- **Meta Contract (MC)**: A library implementing the UCS (Upgradeable Clone for Scalable Contracts) architecture, providing the foundation for TextDAO's upgradeable and scalable design.

## Getting Started

### Prerequisites

- foundry: 0.2.0 or later
- mc: 0.1.0 or later
- solidity compiler: v0.8.24 or later

### Compiling Contracts

To compile the contracts, run:

```
forge build
```

### Running Tests

To run the test suite, execute:

```
forge test
```

## Documentation

For more detailed information about the TextDAO contracts, please refer to the following documentation:

- [Architecture Overview](docs/architecture/index.md)
- [Development Guide](docs/development/index.md)
- [Contract Interaction Guide](docs/guides/contract-interaction.md)

## Contributing

Contributions to the TextDAO contracts are welcome. Please read our [Contributing Guide](../../CONTRIBUTING.md) for more information on how to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
