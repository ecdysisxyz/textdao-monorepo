// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "@mc-devkit/Flattened.sol";

import {Schema} from "bundle/textdao/storages/Schema.sol";
// Main core functions
import {Propose} from "bundle/textdao/functions/onlyMember/Propose.sol";
import {RawFulfillRandomWords} from "bundle/textdao/functions/onlyVrfCoordinator/RawFulfillRandomWords.sol";
import {Fork} from "bundle/textdao/functions/onlyReps/Fork.sol";
import {Vote} from "bundle/textdao/functions/onlyReps/Vote.sol";
import {Tally} from "bundle/textdao/functions/Tally.sol";
import {Execute} from "bundle/textdao/functions/Execute.sol";
// Main protected functions
import {SaveTextProtected} from "bundle/textdao/functions/protected/SaveTextProtected.sol";
// Cheats
import {OnlyAdminCheats} from "bundle/textdao/functions/_cheat/OnlyAdminCheats.sol";

import {DrinkDAOFacade} from "bundle/textdao/interfaces/DrinkDAOFacade.sol";

/**
 * @title DrinkDAODeployer
 * @dev Library for deploying and initializing DrinkDAO contracts
 */
library DrinkDAODeployer {
    /**
     * @dev Deploys the TextDAO contract with cheat functions and initializes with an admin
     * @param mc MCDevKit storage reference
     * @param admin Address of the initial admin who can cheat
     * @return textDAO Address of the deployed TextDAO proxy
     */
    function deployWithCheats(MCDevKit storage mc, address admin, Schema.DeliberationConfig memory initialConfig) internal returns(address textDAO) {
        mc.init("DrinkDAO");

        // DrinkDAO core functions
        mc.use("Propose", Propose.propose.selector, address(new Propose()));
        mc.use("ForkCommand", Fork.forkCommand.selector, address(new Fork()));
        mc.use("Vote", Vote.vote.selector, address(new Vote()));
        address tally = address(new Tally());
        mc.use("Tally", Tally.tally.selector, tally);
        mc.use("TallyAndExecute", Tally.tallyAndExecute.selector, tally);
        mc.use("Execute", Execute.execute.selector, address(new Execute()));

        // DrinkDAO protected functions
        mc.use("CreateText", SaveTextProtected.createText.selector, address(new SaveTextProtected()));

        // Cheats
        address onlyAdminCheats = address(new OnlyAdminCheats());
        mc.use("Initialize", OnlyAdminCheats.initialize.selector, onlyAdminCheats);
        mc.use("AddAdmins", OnlyAdminCheats.addAdmins.selector, onlyAdminCheats);
        mc.use("AddMembers", OnlyAdminCheats.addMembers.selector, onlyAdminCheats);
        mc.use("AddReps", OnlyAdminCheats.addReps.selector, onlyAdminCheats);
        mc.use("UpdateConfig", OnlyAdminCheats.updateConfig.selector, onlyAdminCheats);
        mc.use("ForceTally", OnlyAdminCheats.forceTally.selector, onlyAdminCheats);
        mc.use("GetCurrentScores", OnlyAdminCheats.getCurrentScores.selector, onlyAdminCheats);
        mc.use("GetCurrentTopIds", OnlyAdminCheats.getCurrentTopIds.selector, onlyAdminCheats);
        mc.use("GetCurrentTopScores", OnlyAdminCheats.getCurrentTopScores.selector, onlyAdminCheats);
        mc.use("ExtendExpirationTimeCheat", OnlyAdminCheats.extendExpirationTime.selector, onlyAdminCheats);
        mc.use("ForceApprove", OnlyAdminCheats.forceApprove.selector, onlyAdminCheats);
        mc.use("ForceApproveAndExecute", OnlyAdminCheats.forceApproveAndExecute.selector, onlyAdminCheats);

        // Facade
        mc.useFacade(address(new DrinkDAOFacade())); // for Etherscan proxy read/write

        return mc.deploy(
            abi.encodeCall(OnlyAdminCheats.initialize,
                (admin, initialConfig)
            )
        ).toProxyAddress();
    }
}
