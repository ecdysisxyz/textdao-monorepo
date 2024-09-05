---
title: "TextDAO Project Structure"
version: 0.1.0
lastUpdated: 2024-09-04
author: TextDAO Development Team
scope: project
type: guide
tags: [project-structure, directory-layout, file-organization]
relatedDocs: [../README.md, ../CONTRIBUTING.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-04
    description: Initial version of the project structure documentation
---

# TextDAO Project Structure

This document outlines the directory structure and file organization of the TextDAO project. Understanding this structure is crucial for efficient development, maintenance, and onboarding of new team members.

## Directory Structure

```
textdao-monorepo/
├── packages/
│   ├── contracts/
│   │   ├── src/
│   │   ├── test/
│   │   ├── docs/
│   │   └── README.md
│   │
│   ├── subgraph/
│   │   ├── src/
│   │   ├── schema.graphql
│   │   ├── docs/
│   │   └── README.md
│   │
│   ├── frontend/
│   │   ├── src/
│   │   ├── public/
│   │   ├── docs/
│   │   └── README.md
│   │
│   ├── keeper/
│   │   ├── src/
│   │   ├── docs/
│   │   └── README.md
│   │
│   └── documentation/
│       ├── docs/
│       ├── src/
│       ├── static/
│       ├── docusaurus.config.js
│       └── README.md
│
├── docs/
│   ├── versioning.md
│   ├── glossary.md
│   ├── project-structure.md
│   └── documentation-guidelines.md
│
├── README.md
└── CONTRIBUTING.md
```

## Key Directories and Files

### packages/contracts/

Contains the smart contract code for TextDAO and HubDAO.

- `src/`: Smart contract source files
- `test/`: Contract test files
- `docs/`: Contract-specific documentation

### packages/subgraph/

The Graph protocol indexer for TextDAO events.

- `src/`: Subgraph source files
- `schema.graphql`: GraphQL schema for the subgraph
- `docs/`: Subgraph-specific documentation

### packages/frontend/

React-based user interface for TextDAO.

- `src/`: React application source files
- `public/`: Static assets
- `docs/`: Frontend-specific documentation

### packages/keeper/

Off-chain automation services for TextDAO.

- `src/`: Keeper service source files
- `docs/`: Keeper-specific documentation

### packages/documentation/

Docusaurus-based documentation site.

- `docs/`: Markdown files for the documentation site
- `src/`: Custom React components for the documentation site
- `static/`: Static assets for the documentation site
- `docusaurus.config.js`: Docusaurus configuration file

### docs/

Project-wide documentation files.

- `versioning.md`: Versioning guidelines
- `glossary.md`: Project glossary
- `project-structure.md`: This file
- `documentation-guidelines.md`: Guidelines for writing documentation

## Naming Conventions

- React components use PascalCase (e.g., `ProposalList.tsx`)
- Other JavaScript/TypeScript files use camelCase (e.g., `utils.ts`)
- Test files are suffixed with `.test.ts` or `.test.tsx`
- Solidity files use PascalCase (e.g., `TextDAO.sol`)
- Documentation files use kebab-case (e.g., `project-structure.md`)

## Best Practices

1. Keep related functionality in the same directory.
2. Use clear and descriptive names for files and directories.
3. Maintain README files in key directories to provide additional context.
4. Follow the established naming conventions consistently.
5. Update this document when making significant changes to the project structure.
