---
title: "TextDAO Frontend"
version: 0.1.0
lastUpdated: 2024-09-05
author: TextDAO Development Team
scope: frontend
type: readme
tags: [frontend, react, vite, typescript]
relatedDocs: [docs/architecture/index.md, docs/development/index.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-05
    description: Initial version of the TextDAO Frontend README
---

# TextDAO Frontend

This package contains the frontend application for TextDAO, providing a user interface for interacting with TextDAO smart contracts and subgraph data.

## Technologies Used

- React
- TypeScript
- Vite
- TanStack Router
- TanStack Query
- Tailwind CSS

## Getting Started

To set up and run the TextDAO frontend locally:

1. Install dependencies:
   ```
   bun install
   ```

2. Set up environment variables:
   ```
   cp .env.example .env.local
   ```
   Edit `.env.local` and fill in the required values.

3. Start the development server:
   ```
   bun dev
   ```

The application will be available at `http://localhost:8080`.

## Project Structure

```
frontend/
├── src/
│   ├── components/
│   ├── hooks/
│   ├── lib/
│   ├── query/
│   ├── routes/
│   ├── App.tsx
│   └── main.tsx
├── public/
│   └── locales
│         └── [name spance directory]
│               ├── en.json
│               └── ja.json
├── tests/
├── vite.config.ts
└── package.json
```

## Available Scripts

- `bun dev`: Starts the development server
- `bun build`: Builds the production-ready application
- `bun test`: Runs the test suite
- `bun lint`: Lints the codebase using biome
- `bun format`: Formats the codebase using biome

## Documentation

For more detailed information, please refer to the following documentation:

- [Architecture Overview](docs/architecture/index.md)
- [Development Guide](docs/development/index.md)

## Contributing

Contributions to the TextDAO frontend are welcome. Please refer to the [CONTRIBUTING.md](../../CONTRIBUTING.md) file in the root of the monorepo for guidelines.

## License

This project is licensed under the [MIT License](LICENSE).
