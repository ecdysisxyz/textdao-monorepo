// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Library
import {ProxyCreator} from "@mc-std/functions/internal/ProxyCreator.sol";
// TextDAO
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";
import {IInitialize as ITextDAOInitialize} from "bundle/textdao/interfaces/TextDAOFunctions.sol";
import {Initialize as TextDAOInitialize} from "bundle/textdao/functions/initializer/Initialize.sol";

// Storage
import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
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
    /**
     * @notice Creates a new TextDAO
     * @param initialMembers The initial members of the DAO
     * @param initialConfig The initial configuration for the DAO
     * @param metadataCid The IPFS CID of the DAO metadata
     * @return textDAO The address of the newly created TextDAO
     */
    function createTextDAO(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAO) {
        textDAO = ProxyCreator.create(
            Storage.MetaState().templates[Schema.TemplateType.TextDAO].dictionary,
            abi.encodeCall(TextDAOInitialize.initialize, (initialMembers, initialConfig))
        );
        Schema.Dao memory daoInfo = Schema.Dao({
            addr: textDAO,
            daoType: Schema.TemplateType.TextDAO,
            metadataCid: metadataCid
        });
        Storage.DaoRegistry().daos[textDAO] = daoInfo;
        emit HubDAOEvents.DaoCreated(textDAO);
        emit HubDAOEvents.DaoRegistered(daoInfo);
    }

    /**
     * @notice Creates a new TextDAO with cheats enabled (for testing purposes)
     * @param initialMembers The initial members of the DAO
     * @param initialConfig The initial configuration for the DAO
     * @param metadataCid The IPFS CID of the DAO metadata
     * @return textDAOWithCheats The address of the newly created TextDAO with cheats
     */
    function createTextDAOWithCheats(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAOWithCheats) {
        textDAOWithCheats = ProxyCreator.create(
            Storage.MetaState().templates[Schema.TemplateType.TextDAOWithCheats].dictionary,
            abi.encodeCall(ITextDAOInitialize.initialize, (initialMembers, initialConfig))
        );
        Schema.Dao memory daoInfo = Schema.Dao({
            addr: textDAOWithCheats,
            daoType: Schema.TemplateType.TextDAOWithCheats,
            metadataCid: metadataCid
        });
        Storage.DaoRegistry().daos[textDAOWithCheats] = daoInfo;
        emit HubDAOEvents.DaoCreated(textDAOWithCheats);
        emit HubDAOEvents.DaoRegistered(daoInfo);
    }

}


/// Testing
import {MCTest, vm} from "@devkit/Flattened.sol";
import {IDictionaryCore} from "@ucs.mc/dictionary/interfaces/IDictionaryCore.sol";

/**
 * @title CreateDAOTest
 * @notice Test contract for the CreateDAO contract
 */
contract CreateDAOTest is MCTest {
    address _textDAOInitialize = address(new TextDAOInitialize());
    address _dictionary = makeAddr("DummyDictionary");

    function setUp() public {
        address createDAO = address(new CreateDAO());
        _use(CreateDAO.createTextDAO.selector, createDAO);
        _use(CreateDAO.createTextDAOWithCheats.selector, createDAO);

        bytes memory _bytecode = "dummy bytecode";
        vm.etch(_dictionary, _bytecode);
        vm.mockCall(
            _dictionary,
            abi.encodeCall(IDictionaryCore.getImplementation, (TextDAOInitialize.initialize.selector)),
            abi.encode(_textDAOInitialize)
        );

    }

    /**
     * @notice Test successful creation of a TextDAO
     */
    function test_createTextDAO_success() public {
        Storage.MetaState().templates[Schema.TemplateType.TextDAO] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: _dictionary
        });

        TextDAOSchema.Member[] memory initialMembers = new TextDAOSchema.Member[](1);
        initialMembers[0] = TextDAOSchema.Member({
            addr: address(this),
            metadataCid: "ipfs://test"
        });

        TextDAOSchema.DeliberationConfig memory initialConfig = TextDAOSchema.DeliberationConfig({
            expiryDuration: 1 days,
            snapInterval: 1 hours,
            repsNum: 3,
            quorumScore: 100
        });

        string memory metadataCid = "QmTest";

        address _textDAOAddrPlaceholder = 0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9;

        vm.expectEmit(true, true, true, true);
        emit HubDAOEvents.DaoCreated(_textDAOAddrPlaceholder);
        vm.expectEmit(true, true, true, true);
        emit HubDAOEvents.DaoRegistered(Schema.Dao({
            addr: _textDAOAddrPlaceholder,
            daoType: Schema.TemplateType.TextDAO,
            metadataCid: metadataCid
        }));

        address textDAO = CreateDAO(target).createTextDAO(initialMembers, initialConfig, metadataCid);

        assertNotEq(textDAO, address(0), "TextDAO should be created with a non-zero address");
        assertEq(uint8(Storage.DaoRegistry().daos[textDAO].daoType), uint8(Schema.TemplateType.TextDAO), "Incorrect DAO type");
        assertEq(Storage.DaoRegistry().daos[textDAO].metadataCid, metadataCid, "Incorrect metadata CID");
    }

    /**
     * @notice Test successful creation of a TextDAO with cheats
     */
    function test_createTextDAOWithCheats_success() public {
        Storage.MetaState().templates[Schema.TemplateType.TextDAOWithCheats] = Schema.Template({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            dictionary: _dictionary
        });

        TextDAOSchema.Member[] memory initialMembers = new TextDAOSchema.Member[](1);
        initialMembers[0] = TextDAOSchema.Member({
            addr: address(this),
            metadataCid: "ipfs://test"
        });

        TextDAOSchema.DeliberationConfig memory initialConfig = TextDAOSchema.DeliberationConfig({
            expiryDuration: 1 days,
            snapInterval: 1 hours,
            repsNum: 3,
            quorumScore: 100
        });

        string memory metadataCid = "QmTestCheats";

        address _textDAOAddrPlaceholder = 0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9;

        vm.expectEmit(true, true, true, true);
        emit HubDAOEvents.DaoCreated(_textDAOAddrPlaceholder); // We can't predict the exact address, so we use a placeholder
        vm.expectEmit(true, true, true, true);
        emit HubDAOEvents.DaoRegistered(Schema.Dao({
            addr: _textDAOAddrPlaceholder, // Placeholder
            daoType: Schema.TemplateType.TextDAOWithCheats,
            metadataCid: metadataCid
        }));

        address textDAOWithCheats = CreateDAO(target).createTextDAOWithCheats(initialMembers, initialConfig, metadataCid);

        assertNotEq(textDAOWithCheats, address(0), "TextDAO with cheats should be created with a non-zero address");
        assertEq(uint8(Storage.DaoRegistry().daos[textDAOWithCheats].daoType), uint8(Schema.TemplateType.TextDAOWithCheats), "Incorrect DAO type");
        assertEq(Storage.DaoRegistry().daos[textDAOWithCheats].metadataCid, metadataCid, "Incorrect metadata CID");
    }
}
