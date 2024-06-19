// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

abstract contract OnlyMemberBase {
    modifier onlyMember() {
        Schema.Member[] storage $members = Storage.Members().members;

        bool result;
        for (uint i; i < $members.length; ++i) {
            if ($members[i].addr == msg.sender) {
                result = true;
                break;
            }
        }
        if (!result) revert TextDAOErrors.YouAreNotTheMember();

        _;
    }

}
