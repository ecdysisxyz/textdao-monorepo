// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {MembersLib} from "bundle/textDAO/storages/utils/MembersLib.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

abstract contract OnlyMemberBase {
    using MembersLib for Schema.Members;

    modifier onlyMember() {
        if (!Storage.Members().isMember(msg.sender)) {
            revert TextDAOErrors.YouAreNotTheMember();
        }

        _;
    }
}
