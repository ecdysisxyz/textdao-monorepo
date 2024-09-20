---
title: "TextDAO Contracts Coding Standards"
version: 0.1.0
lastUpdated: 2024-09-04
author: TextDAO Development Team
scope: contracts
type: guide
tags: [smart-contracts, coding-standards, solidity, best-practices]
relatedDocs: [
  "index.md",
  "mc-devkit-usage.md",
  "../architecture/index.md"
]
changeLog:
  - version: 0.1.0
    date: 2024-09-04
    description: Initial version of the coding standards for TextDAO contracts
---

# TextDAO Contracts Coding Standards

This document outlines the coding standards and best practices for developing smart contracts in the TextDAO project. Adhering to these standards ensures consistency, readability, and maintainability across the codebase.

## General Guidelines

1. Use Solidity version 0.8.24 or later.
2. Follow the official [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html) as a baseline.
3. Use `pragma solidity ^0.8.24;` at the beginning of each file.

## Naming Conventions

### Contracts and Libraries
- Use PascalCase
  Example: `MyContract`, `TextDAOLibrary`

### Interfaces
- Prefix with `I` and use PascalCase
  Example: `IMyInterface`, `ITextDAO`

### Functions
- Use camelCase
- Prefix internal functions in contracts with an underscore (_)
- Do not prefix internal functions in libraries with an underscore
  Example: `myFunction`, `calculateTotal`, `_internalFunction` (in contracts)

### Variables
- Use camelCase for function parameters, return variables, and local variables
- Prefix storage variables with `s_`
- Prefix immutable variables with `i_`
- Prefix constant variables with `c_`
  Example: `uint256 totalAmount`, `address s_owner`, `uint256 i_maxSupply`, `uint256 public constant c_MAX_SUPPLY = 1000000`

### Events
- Use PascalCase
- Prefix warning events with `WARN_`
  Example: `TransferEvent`, `ProposalCreated`, `WARN_InsufficientFunds`

### Modifiers
- Use mixedCase
  Example: `onlyOwner`, `nonReentrant`

### Enums
- Use PascalCase for enum name, and ALL_CAPS for values
  Example:
  ```solidity
  enum Color { RED, GREEN, BLUE }
  ```

### Struct
- Use PascalCase
  Example: `struct UserInfo { ... }`

## Code Layout

- Use 4 spaces for indentation (not tabs).
- Maximum line length is 120 characters.
- Use single quotes for strings.
- Place the opening brace on the same line as the declaration.
- Place the closing brace on a new line.

Example:

```solidity
contract MyContract {
    uint256 private constant c_MAX_VALUE = 100;

    function calculateSum(uint256 a, uint256 b) public pure returns (uint256) {
        require(a < c_MAX_VALUE && b < c_MAX_VALUE, 'Values too large');
        return a + b;
    }
}
```

## Documentation

- Use NatSpec comments for all public and external functions and state variables.
- Write clear and concise comments explaining complex logic.
- Keep comments up-to-date when changing code.

Example:

```solidity
/// @notice Calculates the sum of two numbers
/// @param a The first number
/// @param b The second number
/// @return The sum of a and b
function calculateSum(uint256 a, uint256 b) public pure returns (uint256) {
    // Ensure inputs are within acceptable range
    require(a < c_MAX_VALUE && b < c_MAX_VALUE, 'Values too large');
    return a + b;
}
```

## Security Considerations

- Use the `checks-effects-interactions` pattern to prevent reentrancy.
- Be cautious with `delegatecall` and understand its implications.
- Use `transfer()` or `call.value()()` with checks for ETH transfers.
- Avoid using `tx.origin` for authentication.
- Use SafeMath for versions < 0.8.0 (for 0.8.0 and later, built-in overflow checks are sufficient).

## Gas Optimization

- Use `uint256` instead of `uint8`, `uint16`, etc., unless packing into structs.
- Avoid loops with unbounded length.
- Use `memory` for read-only arrays, `storage` for modifiable state.
- Use events to store data that doesn't need to be accessed by smart contracts.

## Testing

- Write comprehensive unit tests for all functions.
- Use the MC DevKit for enhanced testing capabilities.
- Implement fuzzing tests for critical functions.
- Test for edge cases and boundary conditions.

## Meta Contract (MC) Specific Guidelines

- Use the MC DevKit for state management and testing.
- Follow the UCS (Upgradeable Clone for Scalable Contracts) pattern for upgradeable contracts.
- Use proper storage management techniques to prevent storage conflicts.

Example of MC DevKit usage in tests:

```solidity
import {MCTest} from "@mc-devkit/Flattened.sol";

contract MyContractTest is MCTest {
    function setUp() public {
        _use(MyContract.someFunction.selector, address(new MyContract()));
    }

    function test_someFunction_success() public {
        // Test implementation
        (bool success, ) = target.call(abi.encodeWithSelector(MyContract.someFunction.selector, arg1, arg2));
        assertTrue(success);
    }
}
```

## Version Control

- Use descriptive commit messages that explain the purpose of the changes.
- Create feature branches for new developments and use pull requests for code reviews.
- Tag releases with semantic versioning (e.g., v1.0.0, v1.1.0).

## Continuous Integration

- Integrate automated testing into the CI/CD pipeline.
- Ensure all tests pass before merging changes into the main branch.
- Use static analysis tools (e.g., Slither, Mythril) as part of the CI process.

## Conclusion

By adhering to these coding standards, we ensure consistency, readability, and maintainability across the TextDAO smart contracts. These standards should be followed by all contributors to the project. Regular code reviews and automated linting tools should be used to enforce these standards.

Remember that while these guidelines are important, they should not impede productivity or innovation. Use your judgment and discuss with the team if you believe a deviation from these standards is warranted in a specific case.
