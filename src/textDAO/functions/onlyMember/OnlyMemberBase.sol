// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {MembersLib} from "bundle/textDAO/utils/MembersLib.sol";
// Interface
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
