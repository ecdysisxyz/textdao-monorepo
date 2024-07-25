// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit, Dictionary_1 as Dictionary} from "@devkit/Flattened.sol";
import {TextDAODeployer} from "script/TextDAODeployer.sol";

import {OnlyAdminCheats} from "bundle/textDAO/functions/_cheat/OnlyAdminCheats.sol";
import {Tally} from "bundle/textDAO/functions/Tally.sol";
import {Initialize} from "bundle/textDAO/functions/initializer/Initialize.sol";
import {ITextDAO} from "bundle/textDAO/interfaces/ITextDAO.sol";

import {TextDAOWithCheatsFacade} from "bundle/textDAO/interfaces/TextDAOFacade.sol";

library TextDAOOps {
    function upgradeToTextDAOWithCheats(MCDevKit storage mc, address textDAO) internal {
        address onlyAdminCheats = address(new OnlyAdminCheats());
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        _dictionary.set(OnlyAdminCheats.addMembers.selector, onlyAdminCheats);
        _dictionary.set(OnlyAdminCheats.updateConfig.selector, onlyAdminCheats);
        _dictionary.set(OnlyAdminCheats.transferAdmin.selector, onlyAdminCheats);
        _dictionary.set(OnlyAdminCheats.forceTally.selector, onlyAdminCheats);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
    }

    function upgradeTallyEvent(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        _dictionary.set(Tally.tally.selector, address(new Tally()));
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
    }

    function upgradeAndClone(MCDevKit storage mc, address textDAO, address admin) internal returns(address) {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address cheats = address(new OnlyAdminCheats());
        _dictionary.set(OnlyAdminCheats.addMembers.selector, cheats);
        _dictionary.set(OnlyAdminCheats.transferAdmin.selector, cheats);
        _dictionary.set(OnlyAdminCheats.updateConfig.selector, cheats);
        _dictionary.set(Tally.tally.selector, address(new Tally()));
        _dictionary.set(Initialize.initialize.selector, address(new Initialize()));
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
        return ITextDAO(textDAO).clone(
            abi.encodeCall(Initialize.initialize,
                (TextDAODeployer.initialMember(admin), TextDAODeployer.initialConfig())
            )
        );
    }
}
