// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

/**
 * @title MembersLib v0.1.0
 */
library MembersLib {
    function addMember(Schema.Members storage $members, Schema.Member memory newMember) internal returns(Schema.Member storage) {
        return $members.members.push() = newMember;
    }

    function addMembers(Schema.Members storage $members, Schema.Member[] memory newMembers) internal returns(Schema.Members storage) {
        for (uint i; i < newMembers.length; ++i) {
            addMember($members, newMembers[i]);
        }
        return $members;
    }

    error OnlyYouCanModifyYourOwnProfile();
    event MemberProfileUpdated(string newMetadataURI);
    function updateMemberInfo(Schema.Members storage $members, uint mid, string memory newMetadataURI) internal {
        Schema.Member storage target = $members.members[mid];
        if (msg.sender != target.addr) revert OnlyYouCanModifyYourOwnProfile();
        target.metadataURI = newMetadataURI;
        emit MemberProfileUpdated(newMetadataURI);
    }

}
