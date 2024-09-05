---
title: "TextDAO Frontend UI Components"
version: 0.1.0
lastUpdated: 2024-09-05
author: TextDAO Development Team
scope: frontend
type: architecture
tags: [frontend, ui, components, react, radix-ui]
relatedDocs: [index.md, ../development/ui-component-development.md]
changeLog:
  - version: 0.1.0
    date: 2024-09-05
    description: Initial version of the TextDAO Frontend UI Components documentation
---

# TextDAO Frontend UI Components

This document provides an overview of the UI components used in the TextDAO frontend application. It covers the component library, custom components, and best practices for component usage.

## Component Library

TextDAO uses [radix-ui](https://www.radix-ui.com/) as the base component library. radix-ui provides a set of accessible, customizable React components that we extend and customize for our specific needs.

### Key radix-ui Components Used

- Button
- Input
- Select
- Dialog
- Tabs
- Card
- Avatar
- Toast

## Custom Components

In addition to radix-ui components, we have developed several custom components specific to TextDAO functionality:

### ProposalCard

Displays a summary of a proposal.

```tsx
<ProposalCard
  id={proposal.id}
  title={proposal.title}
  proposer={proposal.proposer}
  createdAt={proposal.createdAt}
  status={proposal.status}
/>
```

### VotingInterface

Allows users to cast votes on proposals.

```tsx
<VotingInterface
  proposalId={proposalId}
  options={votingOptions}
  onVote={handleVote}
/>
```

### MemberList

Displays a list of DAO members.

```tsx
<MemberList
  members={daoMembers}
  onMemberClick={handleMemberClick}
/>
```

### TextEditor

A rich text editor for creating and editing DAO texts.

```tsx
<TextEditor
  initialContent={text.content}
  onChange={handleTextChange}
  onSave={handleTextSave}
/>
```

## Component Architecture

Our components follow these principles:

1. **Composability**: Components are designed to be easily combined and nested.
2. **Prop-driven**: Component behavior and appearance are controlled through props.
3. **Accessibility**: All components are built with accessibility in mind, following WCAG guidelines.
4. **Responsiveness**: Components are designed to work across various screen sizes.

## State Management in Components

- Local component state is managed using React's `useState` hook.
- For more complex state management, we use React Context or TanStack Query.

Example of state management in a component:

```tsx
const ProposalList: React.FC = () => {
  const [filter, setFilter] = useState<ProposalFilter>('all');
  const { data: proposals, isLoading, error } = useProposals(filter);

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error.message} />;

  return (
    <>
      <FilterSelect value={filter} onChange={setFilter} />
      {proposals.map(proposal => (
        <ProposalCard key={proposal.id} {...proposal} />
      ))}
    </>
  );
};
```

## Styling

We use Tailwind CSS for styling components. Custom styles are applied using Tailwind classes directly in the component JSX.

Example:

```tsx
const Button: React.FC<ButtonProps> = ({ children, variant = 'primary' }) => {
  const baseClasses = 'px-4 py-2 rounded-md font-medium';
  const variantClasses = {
    primary: 'bg-blue-500 text-white hover:bg-blue-600',
    secondary: 'bg-gray-200 text-gray-800 hover:bg-gray-300',
  };

  return (
    <button className={`${baseClasses} ${variantClasses[variant]}`}>
      {children}
    </button>
  );
};
```

## Component Documentation

Each component should have its own documentation, including:

- Purpose and usage
- Props interface
- Example usage
- Any important notes or caveats

We use JSDoc comments for in-code documentation:

```tsx
/**
 * ProposalCard component displays a summary of a proposal.
 * @param {Object} props - The component props
 * @param {string} props.id - The proposal ID
 * @param {string} props.title - The proposal title
 * @param {string} props.proposer - The address of the proposer
 * @param {number} props.createdAt - The timestamp of when the proposal was created
 * @param {ProposalStatus} props.status - The current status of the proposal
 */
const ProposalCard: React.FC<ProposalCardProps> = ({ id, title, proposer, createdAt, status }) => {
  // Component implementation
};
```

## Testing Components

We use React Testing Library for component testing. Each component should have associated unit tests covering its functionality and user interactions.

Example test:

```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { ProposalCard } from './ProposalCard';

describe('ProposalCard', () => {
  it('renders proposal details correctly', () => {
    render(<ProposalCard id="1" title="Test Proposal" proposer="0x123..." createdAt={1631234567} status="active" />);

    expect(screen.getByText('Test Proposal')).toBeInTheDocument();
    expect(screen.getByText('0x123...')).toBeInTheDocument();
    expect(screen.getByText('Active')).toBeInTheDocument();
  });

  it('calls onClick handler when clicked', () => {
    const handleClick = jest.fn();
    render(<ProposalCard id="1" title="Test Proposal" proposer="0x123..." createdAt={1631234567} status="active" onClick={handleClick} />);

    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledWith('1');
  });
});
```

## Performance Considerations

- Use React.memo for components that render often but rarely change.
- Implement virtualization for long lists (e.g., proposal lists, member lists) using libraries like react-window.
- Optimize images and use lazy loading for images not immediately visible.

## Accessibility

- Ensure all interactive elements are keyboard accessible.
- Use appropriate ARIA attributes where necessary.
- Maintain sufficient color contrast for text and important UI elements.
- Provide text alternatives for non-text content.

## Future Improvements

- Implement a component playground or Storybook for easier component development and documentation.
- Explore the use of CSS-in-JS solutions for more dynamic styling capabilities.
- Investigate the potential for server-side rendering of certain components for improved performance and SEO.

By following these guidelines and continuously improving our component architecture, we can ensure a consistent, accessible, and performant user interface for TextDAO.
