---
title: "TextDAO Documentation"
version: 0.1.0
lastUpdated: 2024-09-06
author: TextDAO Development Team
scope: documentation
type: readme
tags: [documentation, docusaurus, technical-writing]
relatedDocs: [intro.md, docusaurus.config.js]
changeLog:
  - version: 0.1.0
    date: 2024-09-06
    description: Initial version of the TextDAO Documentation README
---

# TextDAO Documentation

This package contains the documentation website for the TextDAO project, built using Docusaurus.

## Overview

The TextDAO documentation site provides comprehensive information about the TextDAO project, including:

- Project overview and concepts
- Technical specifications
- User guides
- API references
- Developer guides

## Technologies Used

- Docusaurus 3
- React
- Markdown
- MDX

## Getting Started

To set up and run the documentation site locally:

1. Install dependencies:
   ```
   bun install
   ```

2. Start the development server:
   ```
   bun start
   ```

The site will be available at `http://localhost:3000`.

## Project Structure

```
documentation/
├── docs/
│   ├── intro.md
│   └── [other documentation files]
├── src/
│   ├── components/
│   ├── css/
│   └── pages/
├── static/
│   └── img/
├── docusaurus.config.js
├── sidebars.js
└── package.json
```

## Available Scripts

- `bun start`: Starts the development server
- `bun run build`: Builds the production-ready website
- `bun serve`: Serves the production build locally
- `bun deploy`: Deploys the site to GitHub Pages (or your configured hosting)

## Writing Documentation

- All documentation files should be written in Markdown or MDX format.
- Place new documentation files in the `docs/` directory.
- Update `sidebars.js` to include new pages in the navigation.
- Use Docusaurus-specific features like admonitions and tabs where appropriate.

## Versioning

We use Docusaurus' built-in versioning feature to maintain documentation for different versions of TextDAO. To create a new version:

```
bun docusaurus docs:version x.x.x
```

## Contributing

Contributions to the TextDAO documentation are welcome. Please refer to the [CONTRIBUTING.md](../../CONTRIBUTING.md) file in the root of the monorepo for guidelines.

## Deployment

The documentation site is automatically deployed via CI/CD pipeline when changes are merged into the main branch. For manual deployment, use:

```
bun deploy
```

## License

This project is licensed under the [MIT License](LICENSE).
