---
title: "TextDAO Keeper"
version: 0.1.0
lastUpdated: 2024-09-06
author: TextDAO Development Team
scope: keeper
type: readme
tags: [keeper, automation, blockchain, ethereum]
relatedDocs: [docs/architecture/index.md, docs/guides/running-keeper.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-06
    description: Initial version of the TextDAO Keeper README
---

# TextDAO Keeper

The TextDAO Keeper is an automated service responsible for executing time-sensitive operations and maintaining the overall health of the TextDAO ecosystem.

## Overview

The Keeper performs critical functions such as:

1. Executing proposals after the voting period has ended
2. Triggering the tally process for active proposals
3. Handling any time-based or condition-based actions required by the DAO

## Key Features

- Automated execution of DAO operations
- Configurable scheduling of tasks
- Robust error handling and retry mechanisms
- Monitoring and logging for operational visibility

## Getting Started

To set up and run the TextDAO Keeper locally:

1. Clone the repository and navigate to the keeper package:
   ```
   git clone git@github.com:ecdysisxyz/textdao-monorepo.git
   cd textdao-monorepo/packages/keeper
   ```

2. Install dependencies:
   ```
   bun install
   ```

3. Set up environment variables:
   ```
   cp .env.example .env
   ```
   Edit the `.env` file with your specific configuration.

4. Build the project:
   ```
   bun build
   ```

5. Start the Keeper:
   ```
   bun start
   ```

For more detailed instructions, see the [Running Keeper Guide](docs/guides/running-keeper.md).

## Configuration

The Keeper can be configured through environment variables and a configuration file. Key configuration options include:

- `ETHEREUM_RPC_URL`: The Ethereum node RPC URL
- `KEEPER_PRIVATE_KEY`: The private key for the Keeper's Ethereum account
- `CHECK_INTERVAL`: How often the Keeper should check for actions (in seconds)

See the [Configuration Guide](docs/guides/configuration.md) for a full list of options.

## Architecture

The Keeper is built with a modular architecture, allowing for easy extension and maintenance. For a detailed overview of the Keeper's architecture, see the [Architecture Documentation](docs/architecture/index.md).

## Development

To contribute to the Keeper's development:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write or update tests as necessary
5. Submit a pull request

Please refer to the [Contribution Guidelines](../../CONTRIBUTING.md) for more details.

## Testing

Run the test suite with:

```
bun test
```

For more information on testing strategies and best practices, see the [Testing Guide](docs/development/testing.md).

## Deployment

For instructions on deploying the Keeper to production environments, see the [Deployment Guide](docs/guides/deployment.md).

## Monitoring and Maintenance

The Keeper includes built-in monitoring and alerting capabilities. For information on setting up monitoring and maintaining the Keeper, see the [Monitoring and Maintenance Guide](docs/guides/monitoring.md).

## Troubleshooting

For common issues and their solutions, refer to the [Troubleshooting Guide](docs/guides/troubleshooting.md).

## License

This project is licensed under the [MIT License](LICENSE).
