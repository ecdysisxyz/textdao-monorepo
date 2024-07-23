// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import {MCScript} from "@devkit/Flattened.sol";

// import {TextDAOWithCheatsFacade} from "bundle/textDAO/interfaces/TextDAOFacade.sol";
// import {Propose} from "bundle/textDAO/functions/onlyMember/Propose.sol";
// import {Vote} from "bundle/textDAO/functions/onlyReps/Vote.sol";

// contract UpgradeTextDAOWithCheatScript is MCScript {
//     function updateFacade() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
//         mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(0xbC2fC4eb14077Fd7F29B948E5Fd39a4634f6D138))
//             .upgradeFacade(address(new TextDAOWithCheatsFacade()));
//     }
// }
