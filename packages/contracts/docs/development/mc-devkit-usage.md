---
title: "MC DevKit Usage Guide"
version: 0.1.0
lastUpdated: 2024-09-04
author: TextDAO Development Team
scope: contracts
type: guide
tags: [smart-contracts, mc-devkit, development, testing, tools]
relatedDocs: [
  "index.md",
  "coding-standards.md",
  "meta-contract-spec.md",
  "test-strategy.md"
]
changeLog:
  - version: 0.1.0
    date: 2024-09-04
    description: Initial version of the MC DevKit usage guide
---

# MC DevKit Usage Guide

The MC DevKit is a crucial tool for developing and testing TextDAO contracts. This guide provides comprehensive information on how to use MC DevKit effectively in your development process.

## Key Features

1. State Fuzzing
2. Storage Management
3. UCS Implementation Tools

## Usage

### State Fuzzing

State Fuzzing enables direct access to Storage information of implementation contracts. This feature allows for more granular and comprehensive unit tests.

Example usage:

```solidity
import "mc-devkit/Flattened.sol";

contract MyTest is MCTest {
    function setUp() public {
        address _tally = address(new Tally());
        _use(Tally.tally.selector, _tally);
    }

    function test_tally_success() public {
        // Arrangements...

        // Act
        Tally(target).tally(0);

        // Assertions...
    }
}
```

### Storage Management

MC DevKit adopts ERC-7201 for storage management, helping prevent storage conflicts in upgradeable contracts.

Example of defining a storage layout with `Schema.sol` and `Storage.sol`:

```solidity
interface Schema {
    /// @custom:storage-location erc7201:BundleName.User
    struct User {
        string name;
        address addr;
    }
}
```

The base slot is calculated with ERC-7201 specification.
```sh
$ cast index-erc7201 BundleName.User
0xcf4c2de7368f2a1dde056d139cb647f22a7ed6bd517e396553affeafe8915b00
```

```solidity
library Storage {
    function layout() internal pure returns (Schema.User storage $) {
        assembly {
            $.slot := 0xcf4c2de7368f2a1dde056d139cb647f22a7ed6bd517e396553affeafe8915b00
        }
    }
}
```

### UCS Implementation

MC DevKit provides tools and utilities for implementing the UCS architecture.

Example of library testing:

```solidity
using DeliberationLib for Schema.Deliberation;
using ProposalLib for Schema.Proposal;

function test_deliberation() public {
    Schema.Deliberation memory delib = // ... initialize deliberation
    delib.someFunction();
    // Assert expected behavior
}
```

## Best Practices

1. Always use MC DevKit's storage management features when working with upgradeable contracts
2. Leverage State Fuzzing for thorough testing of contract states
3. Familiarize yourself with the UCS architecture to make the most of MC DevKit's features
4. Write comprehensive positive and negative tests covering various scenarios and edge cases, including reasonable gas limit
5. Regularly update MC DevKit to benefit from the latest features and security improvements

## Advanced Usage

### Integration with Foundry Cheats

MC DevKit integrates well with Foundry's cheatcodes for advanced testing scenarios:

```solidity
function test_timeDependent() public {
    vm.warp(block.timestamp + 1 days);
    // Test time-dependent functionality...
}
```

## Troubleshooting

Common issues and their solutions:

1. **Issue**: State Fuzzing not working as expected
   **Solution**: Ensure you're using the correct selectors and that your test contract inherits from `MCTest`

2. **Issue**: Storage conflicts in upgradeable contracts
   **Solution**: Double-check that you're using ERC-7201 compliant storage layouts and not directly accessing storage slots

## Further Resources

- [MC DevKit Documentation](https://mc-book.ecdysis.xyz)
- [Example Projects Repository: TextDAO](https://github.com/ecdysisxyz/textdao-monorepo)
- [Community Forums](https://github.com/metacontract/mc/discussions)

## Conclusion

MC DevKit is a powerful tool that enhances the development and testing process for TextDAO contracts. By leveraging its features, you can write more comprehensive tests, manage storage efficiently, and implement the UCS architecture effectively.

Remember to consult the MC DevKit documentation regularly, as new features and improvements are continually being added to support the evolving needs of TextDAO development.

For additional support or to report issues, please visit our [GitHub repository](https://github.com/metacontract/mc/issues).
