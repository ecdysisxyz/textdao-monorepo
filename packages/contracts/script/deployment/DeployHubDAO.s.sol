// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@mc-devkit/Flattened.sol";
import {HubDAODeployer, Schema} from "script/HubDAODeployer.sol";
import {GlobalConfigLib} from "bundle/hubdao/storages/utils/GlobalConfigLib.sol";
import {DaoTemplateLib} from "bundle/hubdao/storages/utils/DaoTemplateLib.sol";
import {TextDAODeployer} from "script/TextDAODeployer.sol";
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";

contract DeployHubDAOScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address _textDaoDictionary = TextDAODeployer.deployDictionary(mc);
        address _hubDAO = HubDAODeployer.deploy({mc: mc,
            baseCurrency: GlobalConfigLib.newCurrency(address(0)),
            templates: DaoTemplateLib.newTemplate(Schema.TemplateType.TextDAO, _textDaoDictionary),
            textDaoDefaultConfig: DeliberationLib.newConfig({
                expiryDuration: 7 days,
                snapInterval: 2 hours,
                repsNum: 100,
                quorumScore: 2
            })
        });
        _saveAddrToEnv(_textDaoDictionary, "TEXT_DAO_DICT_ADDR_");
        _saveAddrToEnv(_hubDAO, "HUB_DAO_ADDR_");
    }
}

contract DeployTextDAOWithCheatScript is MCScript {
    using DaoTemplateLib for Schema.Template[];

    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address _textDaoDictionary = TextDAODeployer.deployDictionary(mc);
        address _textDaoDictionaryWithCheats = TextDAODeployer.deployDictionaryWithCheats(mc);
        address _hubDAO = HubDAODeployer.deployWithCheats({ mc: mc,
            baseCurrency: GlobalConfigLib.newCurrency(address(0)),
            templates: DaoTemplateLib.newTemplate(Schema.TemplateType.TextDAO, _textDaoDictionary)
                                    .addTemplateToMemory(Schema.TemplateType.TextDAOWithCheats, _textDaoDictionaryWithCheats),
            textDaoDefaultConfig: DeliberationLib.newConfig({
                expiryDuration: 7 days,
                snapInterval: 2 hours,
                repsNum: 100,
                quorumScore: 2
            }),
            admin: deployer
        });
        _saveAddrToEnv(_textDaoDictionaryWithCheats, "TEXT_DAO_DICT_CHEAT_ADDR_");
        _saveAddrToEnv(_hubDAO, "HUB_DAO_CHEAT_ADDR_");
    }
}
