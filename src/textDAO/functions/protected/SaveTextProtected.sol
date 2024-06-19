// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

contract SaveTextProtected is ProtectionBase {
    // TODO CRUD
    function saveText(uint pid, uint textId, string[] memory metadataURIs) public protected(pid) returns (bool) {
        Schema.Text storage $text = Storage.Texts().texts.push();

        for (uint i; i < metadataURIs.length; ++i) {
            $text.metadataURIs.push(metadataURIs[i]);
        }
        emit TextDAOEvents.TextSaved(pid, $text);
    }
}
