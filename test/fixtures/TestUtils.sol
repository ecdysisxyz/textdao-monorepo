// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {ForgeHelper} from "@devkit/Flattened.sol";

library TestUtils {
    function setMsgSenderAsMember() internal {
        Storage.Members().members.push().addr = ForgeHelper.msgSender();
    }

    function setMsgSenderAsRep(uint256 pid) internal {
        Storage.DAOState().proposals[pid].proposalMeta.reps.push(ForgeHelper.msgSender());
    }

    function setMsgSenderAsVrfCoordinator() internal {
        Storage.$VRF().config.vrfCoordinator = ForgeHelper.msgSender();
    }
}
