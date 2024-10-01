// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title GlobalConfigLib v0.1.0
 * @dev Library for managing global configurations.
 */
library GlobalConfigLib {
    using GlobalConfigLib for Schema.GlobalConfigs;

    /**
     * @dev Sets the base currency in the global configurations.
     * @param $globalConfigs The global configurations to update.
     * @param currency The currency to set as the base currency.
     * @notice Emits a BaseCurrencyUpdated event on success.
     */
    function setCurrency(Schema.GlobalConfigs storage $globalConfigs, Schema.Currency memory currency) internal {
        $globalConfigs.baseCurrency = currency;
        emit HubDAOEvents.BaseCurrencyUpdated(currency);
    }

    /**
     * @dev Creates a new currency configuration.
     * @param currencyAddr The address of the currency.
     * @return currency The newly created currency configuration.
     */
    function newCurrency(address currencyAddr) internal pure returns(Schema.Currency memory currency) {
        return Schema.Currency({
            addr: currencyAddr
        });
    }
}

// Testing
import {Test} from "forge-std/Test.sol";

contract GlobalConfigLibTest is Test {
    using GlobalConfigLib for Schema.GlobalConfigs;

    Schema.GlobalConfigs private $globalConfigs;

    function setUp() public {} // No setup required for this library test

    function test_setCurrency_success() public {
        Schema.Currency memory _currency = Schema.Currency({
            addr: address(0x9999)
        });

        // Expect the BaseCurrencyUpdated event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.BaseCurrencyUpdated(_currency);

        // Set the currency in the global configurations
        $globalConfigs.setCurrency(_currency);

        // Assert that the base currency is set correctly
        assertEq($globalConfigs.baseCurrency.addr, address(0x9999), "The base currency address should match.");
    }

    function test_newCurrency() public pure {
        address currencyAddr = address(0x8888);
        Schema.Currency memory currency = GlobalConfigLib.newCurrency(currencyAddr);

        // Assert that the new currency is created correctly
        assertEq(currency.addr, currencyAddr, "The currency address should match.");
    }
}
