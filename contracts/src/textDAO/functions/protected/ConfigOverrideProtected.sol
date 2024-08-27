
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

import { Tally } from "bundle/textDAO/functions/Tally.sol";

contract ConfigOverrideProtected is ProtectionBase {
    function overrideProposalsConfig(uint pid, Schema.ConfigOverride memory configOverride) public protected(pid) returns (bool) {
        Schema.ConfigOverrideStorage storage $configOverride = Storage.$ConfigOverride();
        $configOverride.overrides[Tally.tally.selector].quorumScore = configOverride.quorumScore;
    }
}
