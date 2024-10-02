// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Library
import {ProxyCreator} from "@mc-std/functions/internal/ProxyCreator.sol";
// TextDAO
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";
import {IInitialize as ITextDAOInitialize} from "bundle/textdao/interfaces/TextDAOFunctions.sol";
import {Initialize as TextDAOInitialize} from "bundle/textdao/functions/initializer/Initialize.sol";
import {MemberLib} from "bundle/textdao/utils/MemberLib.sol";

// Storage
import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
import {DaoRegistryLib} from "bundle/hubdao/storages/utils/DaoRegistryLib.sol";
import {DaoTemplateLib} from "bundle/hubdao/storages/utils/DaoTemplateLib.sol";
// Interface
import {ICreateDAO} from "bundle/hubdao/interfaces/HubDAOFunctions.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";

/**
 * @title CreateDAO
 * @notice This contract handles the DAO creation process using templates
 * @dev This contract is designed to be called by anyone
 */
contract CreateDAO is ICreateDAO {
    using DaoRegistryLib for Schema.DaoRegistry;
    using DaoTemplateLib for Schema.DaoTemplates;

    /**
     * @notice Creates a new TextDAO
     * @param metadataCid The IPFS CID of the DAO metadata
     * @return textDAO The address of the newly created TextDAO
     * @dev Emits a DAO's `ProxyCreated` event on success
     * @dev Emits `DaoRegistered` event on success
     */
    function createTextDAO(string calldata metadataCid) public returns(address textDAO) {
        return createTextDAOWithParams({
            initialMembers: MemberLib.newMember(msg.sender),
            initialConfig: Storage.TextDaoDefaultConfig(),
            metadataCid: metadataCid
        });
    }

    /**
     * @notice Creates a new TextDAO with specified parameters
     * @param initialMembers The initial members of the DAO
     * @param initialConfig The initial configuration for the DAO
     * @param metadataCid The IPFS CID of the DAO metadata
     * @return textDAO The address of the newly created TextDAO
     * @dev Emits a DAO's `ProxyCreated` event on success
     * @dev Emits `DaoRegistered` event on success
     */
    function createTextDAOWithParams(TextDAOSchema.Member[] memory initialMembers, TextDAOSchema.DeliberationConfig memory initialConfig, string calldata metadataCid) public returns(address textDAO) {
        textDAO = ProxyCreator.create({
            dictionary: Storage.DaoTemplates().getDictionary(Schema.TemplateType.TextDAO),
            initData: abi.encodeCall(TextDAOInitialize.initialize, (initialMembers, initialConfig))
        });

        Storage.DaoRegistry().registerTextDAO(textDAO, metadataCid);
    }

    /**
     * @notice Creates a new TextDAO with cheats enabled (for testing purposes)
     * @param metadataCid The IPFS CID of the DAO metadata
     * @return textDAOWithCheats The address of the newly created TextDAO with cheats
     * @dev Emits a DAO's `ProxyCreated` event on success
     * @dev Emits `DaoRegistered` event on success
     */
    function createTextDAOWithCheats(string calldata metadataCid) public returns(address textDAOWithCheats) {
        return createTextDAOWithCheatsWithParams({
            initialMembers: MemberLib.newMember(msg.sender),
            initialConfig: Storage.TextDaoDefaultConfig(),
            metadataCid: metadataCid
        });
    }

    /**
     * @notice Creates a new TextDAO with cheats enabled and specified parameters (for testing purposes)
     * @param initialMembers The initial members of the DAO
     * @param initialConfig The initial configuration for the DAO
     * @param metadataCid The IPFS CID of the DAO metadata
     * @return textDAOWithCheats The address of the newly created TextDAO with cheats
     * @dev Emits a DAO's `ProxyCreated` event on success
     * @dev Emits `DaoRegistered` event on success
     */
    function createTextDAOWithCheatsWithParams(TextDAOSchema.Member[] memory initialMembers, TextDAOSchema.DeliberationConfig memory initialConfig, string calldata metadataCid) public returns(address textDAOWithCheats) {
        textDAOWithCheats = ProxyCreator.create({
            dictionary: Storage.DaoTemplates().getDictionary(Schema.TemplateType.TextDAOWithCheats),
            initData: abi.encodeCall(ITextDAOInitialize.initialize, (initialMembers, initialConfig))
        });

        Storage.DaoRegistry().registerTextDAOWithCheats(textDAOWithCheats, metadataCid);
    }

}


/// Testing
import {MCTest, vm} from "@mc-devkit/Flattened.sol";
import {IDictionaryCore} from "@ucs.mc/dictionary/interfaces/IDictionaryCore.sol";
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";

/**
 * @title CreateDAOTest
 * @notice Test contract for the CreateDAO contract
 */
contract CreateDAOTest is MCTest {
    using DeliberationLib for TextDAOSchema.DeliberationConfig;
    using DaoTemplateLib for Schema.DaoTemplates;

    address textDAOInitialize = address(new TextDAOInitialize());
    TextDAOSchema.DeliberationConfig defaultConfig = TextDAOSchema.DeliberationConfig({
        expiryDuration: 1 days,
        snapInterval: 1 hours,
        repsNum: 3,
        quorumScore: 100
    });

    function setUp() public {
        address createDAO = address(new CreateDAO());
        _use(CreateDAO.createTextDAO.selector, createDAO);
        _use(CreateDAO.createTextDAOWithParams.selector, createDAO);
        _use(CreateDAO.createTextDAOWithCheats.selector, createDAO);
        _use(CreateDAO.createTextDAOWithCheatsWithParams.selector, createDAO);

        _setDictionary(makeAddr("DummyDictionary"));
        vm.etch(dictionary, "dummy bytecode");
        vm.mockCall(
            dictionary,
            abi.encodeCall(IDictionaryCore.getImplementation, (TextDAOInitialize.initialize.selector)),
            abi.encode(textDAOInitialize)
        );

        // Set up default config in Storage
        Storage.TextDaoDefaultConfig().setConfig(defaultConfig);
    }

    /**
     * @notice Test successful creation of a TextDAO with default parameters
     */
    function test_createTextDAO_success() public {
        Storage.DaoTemplates().addTemplate(Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: dictionary
        }));

        string memory _metadataCid = "QmTest";

        address _textDAOAddrPlaceholder = 0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9;

        TextDAOSchema.Member[] memory _expectedInitialMembers = new TextDAOSchema.Member[](1);
        _expectedInitialMembers[0].addr = address(this);

        _expectEventsEmit({
            expectedAddress: _textDAOAddrPlaceholder,
            expectedType: Schema.TemplateType.TextDAO,
            expectedMetadataCid: _metadataCid,
            expectedInitialMembers: _expectedInitialMembers,
            expectedDefaultConfig: defaultConfig
        });

        address _textDAO = CreateDAO(target).createTextDAO(_metadataCid);

        _assertDaoRegistered({
            daoAddress: _textDAO,
            expectedAddress: _textDAOAddrPlaceholder,
            expectedType: Schema.TemplateType.TextDAO,
            expectedMetadataCid: _metadataCid
        });
    }

    /**
     * @notice Test successful creation of a TextDAO with custom parameters
     */
    function test_createTextDAOWithParams_success() public {
        Storage.DaoTemplates().addTemplate(Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: dictionary
        }));

        TextDAOSchema.Member[] memory _initialMembers = new TextDAOSchema.Member[](2);
        _initialMembers[0] = TextDAOSchema.Member({
            addr: address(this),
            metadataCid: "ipfs://test1"
        });
        _initialMembers[1] = TextDAOSchema.Member({
            addr: address(0x1234),
            metadataCid: "ipfs://test2"
        });

        TextDAOSchema.DeliberationConfig memory _initialConfig = TextDAOSchema.DeliberationConfig({
            expiryDuration: 2 days,
            snapInterval: 2 hours,
            repsNum: 5,
            quorumScore: 200
        });

        string memory _metadataCid = "QmTestCustom";

        address _textDAOAddrPlaceholder = 0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9;

        _expectEventsEmit({
            expectedAddress: _textDAOAddrPlaceholder,
            expectedType: Schema.TemplateType.TextDAO,
            expectedMetadataCid: _metadataCid,
            expectedInitialMembers: _initialMembers,
            expectedDefaultConfig: _initialConfig
        });

        address _textDAO = CreateDAO(target).createTextDAOWithParams(_initialMembers, _initialConfig, _metadataCid);

        _assertDaoRegistered({
            daoAddress: _textDAO,
            expectedAddress: _textDAOAddrPlaceholder,
            expectedType: Schema.TemplateType.TextDAO,
            expectedMetadataCid: _metadataCid
        });
    }

    /**
     * @notice Test successful creation of a TextDAO with cheats using default parameters
     */
    function test_createTextDAOWithCheats_success() public {
        Storage.DaoTemplates().addTemplate(Schema.Template({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            dictionary: dictionary
        }));

        string memory _metadataCid = "QmTestCheats";

        TextDAOSchema.Member[] memory _expectedInitialMembers = new TextDAOSchema.Member[](1);
        _expectedInitialMembers[0].addr = address(this);

        address _textDAOAddrPlaceholder = 0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9;

        _expectEventsEmit({
            expectedAddress: _textDAOAddrPlaceholder,
            expectedType: Schema.TemplateType.TextDAOWithCheats,
            expectedMetadataCid: _metadataCid,
            expectedInitialMembers: _expectedInitialMembers,
            expectedDefaultConfig: defaultConfig
        });

        address _textDAOWithCheats = CreateDAO(target).createTextDAOWithCheats(_metadataCid);

        _assertDaoRegistered({
            daoAddress: _textDAOWithCheats,
            expectedAddress: _textDAOAddrPlaceholder,
            expectedType: Schema.TemplateType.TextDAOWithCheats,
            expectedMetadataCid: _metadataCid
        });
    }

    /**
     * @notice Test successful creation of a TextDAO with cheats using custom parameters
     */
    function test_createTextDAOWithCheatsWithParams_success() public {
        Storage.DaoTemplates().addTemplate(Schema.Template({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            dictionary: dictionary
        }));

        TextDAOSchema.Member[] memory _initialMembers = new TextDAOSchema.Member[](2);
        _initialMembers[0] = TextDAOSchema.Member({
            addr: address(this),
            metadataCid: "ipfs://test1"
        });
        _initialMembers[1] = TextDAOSchema.Member({
            addr: address(0x1234),
            metadataCid: "ipfs://test2"
        });

        TextDAOSchema.DeliberationConfig memory _initialConfig = TextDAOSchema.DeliberationConfig({
            expiryDuration: 2 days,
            snapInterval: 2 hours,
            repsNum: 5,
            quorumScore: 200
        });

        string memory _metadataCid = "QmTestCheatsCustom";

        address _textDAOAddrPlaceholder = 0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9;

        _expectEventsEmit({
            expectedAddress: _textDAOAddrPlaceholder,
            expectedType: Schema.TemplateType.TextDAOWithCheats,
            expectedMetadataCid: _metadataCid,
            expectedInitialMembers: _initialMembers,
            expectedDefaultConfig: _initialConfig
        });

        address _textDAOWithCheats = CreateDAO(target).createTextDAOWithCheatsWithParams(_initialMembers, _initialConfig, _metadataCid);

        _assertDaoRegistered({
            daoAddress: _textDAOWithCheats,
            expectedAddress: _textDAOAddrPlaceholder,
            expectedType: Schema.TemplateType.TextDAOWithCheats,
            expectedMetadataCid: _metadataCid
        });
    }

    //---------------------
    //  Helper Function
    //---------------------

    /**
     * @notice Emits expected events for DAO creation
     * @param expectedAddress The expected address of the DAO
     * @param expectedType The expected type of the DAO
     * @param expectedMetadataCid The expected metadata CID of the DAO
     * @param expectedInitialMembers The expected initial members of the DAO
     * @param expectedDefaultConfig The expected default deliberation config of the DAO
     */
    function _expectEventsEmit(
        address expectedAddress,
        Schema.TemplateType expectedType,
        string memory expectedMetadataCid,
        TextDAOSchema.Member[] memory expectedInitialMembers,
        TextDAOSchema.DeliberationConfig memory expectedDefaultConfig
    ) internal {
        vm.expectEmit();
        // TextDAO Initialize events
        for (uint i; i < expectedInitialMembers.length; ++i) {
            emit TextDAOEvents.MemberAdded(i, expectedInitialMembers[i].addr, expectedInitialMembers[i].metadataCid);
        }
        emit TextDAOEvents.DeliberationConfigUpdated(expectedDefaultConfig);
        emit TextDAOEvents.Initialized(1);

        // HubDAO events
        emit HubDAOEvents.ProxyCreated(dictionary, expectedAddress);
        emit HubDAOEvents.DaoRegistered(Schema.DaoInfo({
            addr: expectedAddress,
            daoType: expectedType,
            metadataCid: expectedMetadataCid
        }));
    }

    /**
     * @notice Asserts that the DAO is registered correctly
     * @param daoAddress The address of the DAO
     * @param expectedAddress The expected address of the DAO
     * @param expectedType The expected type of the DAO
     * @param expectedMetadataCid The expected metadata CID of the DAO
     */
    function _assertDaoRegistered(address daoAddress, address expectedAddress, Schema.TemplateType expectedType, string memory expectedMetadataCid) internal view {
        assertEq(daoAddress, expectedAddress, "Predicted dao address is invalid");
        assertNotEq(daoAddress, address(0), "DAO should be created with a non-zero address");
        assertEq(
            uint8(Storage.DaoRegistry().daoInfos[daoAddress].daoType),
            uint8(expectedType),
            "Incorrect DAO type"
        );
        assertEq(
            Storage.DaoRegistry().daoInfos[daoAddress].metadataCid,
            expectedMetadataCid,
            "Incorrect metadata CID"
        );
    }
}
