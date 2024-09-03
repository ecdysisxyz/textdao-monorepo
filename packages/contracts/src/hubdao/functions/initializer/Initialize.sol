// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
// Storage
import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
// Interface
import {IInitialize} from "bundle/hubdao/interfaces/HubDAOFunctions.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title Initialize
 * @notice This contract handles the initialization process for HubDAO
 * @dev Inherits from Initializable to ensure one-time initialization
 */
contract Initialize is IInitialize, Initializable {
    /**
     * @notice Initializes the HubDAO with base currency and multiple DAO templates
     * @param currency The base currency for the HubDAO
     * @param templates An array of DAO templates to be used
     * @dev This function can only be called once due to the initializer modifier
     */
    function initialize(Schema.Currency calldata currency, Schema.Template[] calldata templates) external initializer {
        Storage.MetaState().baseCurrency = currency;
        emit HubDAOEvents.BaseCurrencyUpdated(currency);
        for (uint i; i < templates.length; ++i) {
            Storage.MetaState().templates[templates[i].daoType] = templates[i];
            emit HubDAOEvents.DaoTemplateUpdated(templates[i]);
        }
    }
}


// Testing
import {MCTest, console2} from "@devkit/Flattened.sol";
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title InitializeTest
 * @notice Test contract for the Initialize contract
 */
contract HubDaoInitializeTest is MCTest {
    function setUp() public {
        _use(Initialize.initialize.selector, address(new Initialize()));
    }

    /**
     * @notice Test successful initialization of HubDAO with multiple templates
     * @param _currency The base currency for testing
     */
    function test_initialize_success(Schema.Currency calldata _currency) public {
        Schema.Template[] memory _templates = new Schema.Template[](2);
        _templates[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x1111111111111111111111111111111111111111)
        });
        _templates[1] = Schema.Template({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            dictionary: address(0x2222222222222222222222222222222222222222)
        });

        vm.expectEmit(true, true, true, true);
        emit HubDAOEvents.BaseCurrencyUpdated(_currency);

        for (uint i; i < _templates.length; ++i) {
            vm.expectEmit(true, true, true, true);
            emit HubDAOEvents.DaoTemplateUpdated(_templates[i]);
        }

        Initialize(target).initialize(_currency, _templates);

        Schema.Currency storage $storedCurrency = Storage.MetaState().baseCurrency;
        assertEq(keccak256(abi.encode($storedCurrency)), keccak256(abi.encode(_currency)), "Stored currency does not match input");

        for (uint i; i < _templates.length; ++i) {
            Schema.Template storage $storedTemplate = Storage.MetaState().templates[_templates[i].daoType];
            assertEq(keccak256(abi.encode($storedTemplate)), keccak256(abi.encode(_templates[i])), "Stored template does not match input");
        }
    }

    /**
     * @notice Test revert on double initialization attempt
     * @param _currency1 The first base currency for testing
     * @param _currency2 The second base currency for testing
     */
    function test_initialize_revert_AlreadyInitialized(
        Schema.Currency calldata _currency1,
        Schema.Currency calldata _currency2
    ) public {
        Schema.Template[] memory _templates1 = new Schema.Template[](1);
        _templates1[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x1111111111111111111111111111111111111111)
        });

        Schema.Template[] memory _templates2 = new Schema.Template[](1);
        _templates2[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            dictionary: address(0x2222222222222222222222222222222222222222)
        });

        Initialize(target).initialize(_currency1, _templates1);

        vm.expectRevert(HubDAOErrors.InvalidInitialization.selector);
        Initialize(target).initialize(_currency2, _templates2);
    }

    /**
     * @notice Test initialization with empty currency and templates array
     */
    function test_initialize_emptyValues() public {
        Schema.Currency memory emptyCurrency;
        Schema.Template[] memory emptyTemplates = new Schema.Template[](0);

        vm.expectEmit(true, true, true, true);
        emit HubDAOEvents.BaseCurrencyUpdated(emptyCurrency);

        Initialize(target).initialize(emptyCurrency, emptyTemplates);

        Schema.Currency storage $storedCurrency = Storage.MetaState().baseCurrency;
        assertEq(keccak256(abi.encode($storedCurrency)), keccak256(abi.encode(emptyCurrency)), "Stored currency should be empty");

        // Check that no templates are stored
        for (uint i = 0; i <= uint(type(Schema.TemplateType).max); ++i) {
            Schema.Template storage $storedTemplate = Storage.MetaState().templates[Schema.TemplateType(i)];
            assertEq(uint8($storedTemplate.daoType), uint8(Schema.TemplateType.undefined), "Stored template should be undefined");
            assertEq($storedTemplate.dictionary, address(0), "Stored template dictionary should be zero address");
        }
    }
}
