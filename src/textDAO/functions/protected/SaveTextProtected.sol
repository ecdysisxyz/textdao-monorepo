// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { ProtectionBase } from "bundle/textDAO/functions/protected/ProtectionBase.sol";

contract SaveTextProtected is ProtectionBase {
    event TextSaved(uint pid, Schema.Text text);

    // TODO CRUD
    function saveText(uint pid, uint textId, string[] memory metadataURIs) public protected(pid) returns (bool) {
        Schema.Text storage $text = Storage.Texts().texts.push();

        for (uint i; i < metadataURIs.length; ++i) {
            $text.metadataURIs.push(metadataURIs[i]);
        }
        emit TextSaved(pid, $text);
    }
}
