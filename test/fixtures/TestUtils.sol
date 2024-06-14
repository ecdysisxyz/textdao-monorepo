// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {ForgeHelper} from "@devkit/Flattened.sol";

library TestUtils {
    function setMsgSenderAsMember() internal {
        Storage.$Members().members[0].addr = ForgeHelper.msgSender();
        Storage.$Members().nextMemberId = 1;
    }

    function setMsgSenderAsRep(uint256 pid) internal {
        Storage.$Proposals().proposals[pid].proposalMeta.reps.push(ForgeHelper.msgSender());
    }

    function setMsgSenderAsVrfCoordinator() internal {
        Storage.$VRF().config.vrfCoordinator = ForgeHelper.msgSender();
    }
}
