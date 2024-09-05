---
title: "TextDAO Frontend Development Guide"
version: 0.1.0
lastUpdated: 2024-09-05
author: TextDAO Development Team
scope: frontend
type: guide
tags: [frontend, development, react, vite]
relatedDocs: [ui-component-development.md, test-strategy.md, ../architecture/index.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-05
    description: Initial version of the TextDAO Frontend Development Guide
---

# TextDAO Frontend Development Guide

This guide provides essential information for developers working on the TextDAO frontend. It covers setup, development workflow, best practices, and testing processes.

## Development Environment Setup

### Prerequisites

- node.js: version 18 or later

### Setup flow

1. Clone the TextDAO monorepo and navigate to the frontend package:
   ```
   git clone git@github.com:ecdysisxyz/textdao-monorepo.git
   cd textdao-monorepo/packages/frontend
   ```
2. Install dependencies:
   ```
   bun install
   ```
3. Set up environment variables:
   ```
   cp .env.example .env.local
   ```
   Edit `.env.local` and fill in the required values.
4. Start the development server:
   ```
   bun dev
   ```

The application will be available at `http://localhost:8080`.


## Development Workflow

1. Start the development server:
   ```
   bun dev
   ```
2. Make changes to the code. The development server will automatically reload with your changes.
3. Run tests to ensure your changes haven't broken existing functionality:
   ```
   bun test
   ```
4. Lint and format your code:
   ```
   bun lint
   bun format
   ```

## Coding Standards

Please adhere to the following coding standards:

- Use TypeScript for all new code.
- Follow the [React Hooks](https://reactjs.org/docs/hooks-intro.html) pattern for state management and side effects.
- Use functional components instead of class components.
- Use Tailwind CSS for styling. Avoid writing custom CSS unless absolutely necessary.
- Follow the [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript) for general JavaScript/TypeScript practices.

For more detailed coding standards, refer to the [Coding Standards](coding-standards.md) document.

## UI Component Development

When developing new UI components or modifying existing ones, follow these guidelines:

1. Create components in the `src/components` directory.
2. Use TypeScript PropTypes for component props.
3. Write unit tests for each component.
4. Document component usage with JSDoc comments.

For a more comprehensive guide on UI component development, see the [UI Component Development](ui-component-development.md) document.

## State Management

- Use React's built-in useState and useContext hooks for local and global state management.
- Utilize TanStack Query for server state management and caching.
- Avoid using additional state management libraries unless absolutely necessary.

## Routing

Use TanStack Router for all routing needs. Define routes in the `src/routes` directory and ensure they are properly typed.

## API Integration

- Use TanStack Query for all API calls.
- Define API hooks in the `src/hooks` directory.
- Use environment variables for API endpoints and other configuration.

## Testing

Comprehensive testing is crucial for maintaining the reliability and functionality of the frontend. See the [Test Strategy](test-strategy.md) document for information on writing and running tests.

## Performance Optimization

- Use React.memo for components that render often but rarely change.
- Implement code splitting using React.lazy and Suspense.
- Optimize images and other assets for web delivery.
- Use performance profiling tools to identify and resolve bottlenecks.

## Accessibility

- Ensure all components are keyboard accessible.
- Use appropriate ARIA attributes where necessary.
- Test with screen readers to ensure compatibility.

## Internationalization

- Use react-i18next for all user-facing strings.
- Store translations in JSON files in the `public/locales/<name spaces>/` directory.

## Deployment

The deployment process is handled by our CI/CD pipeline. To trigger a deployment:

1. Merge your changes into the `main` branch.
2. The CI/CD pipeline will automatically build and deploy the frontend to the staging environment.
3. After approval, the changes will be promoted to the production environment.

## Troubleshooting

Common issues and their solutions:

1. **Build failures**: Ensure all dependencies are installed and TypeScript types are correct.
2. **API connectivity issues**: Check environment variables and network settings.
3. **Performance problems**: Use React DevTools and browser developer tools to identify bottlenecks.

## Contributing

Contributions to the TextDAO frontend are welcome. Please follow these steps:

1. Fork the repository and create a new branch for your feature or bug fix.
2. Make your changes, ensuring they adhere to the coding standards.
3. Write or update tests as necessary.
4. Submit a pull request with a clear description of your changes.

For more detailed contribution guidelines, please refer to the [CONTRIBUTING.md](../../../../CONTRIBUTING.md) file in the root of the monorepo.

## Additional Resources

- [React Documentation](https://reactjs.org/docs/getting-started.html)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [Vite Documentation](https://vitejs.dev/guide/)
- [TanStack Query Documentation](https://tanstack.com/query/latest)
- [TanStack Router Documentation](https://tanstack.com/router/latest)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

If you encounter any issues or have questions not covered in this guide, please reach out to the TextDAO development team or open an issue in the repository.
