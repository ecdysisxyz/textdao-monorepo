// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

/**
 * @title MembersLib v0.1.0
 */
library MembersLib {
    function addMember(Schema.Members storage $, Schema.Member memory newMember) internal returns(Schema.Member storage) {
        return $.members.push() = newMember;
    }

    function addMembers(Schema.Members storage $, Schema.Member[] memory newMembers) internal returns(Schema.Members storage) {
        for (uint i; i < newMembers.length; ++i) {
            addMember($, newMembers[i]);
        }
        return $;
    }

    error OnlyYouCanModifyYourOwnProfile();
    event MemberProfileUpdated(string newMetadataURI);
    function updateMemberInfo(Schema.Members storage $, uint mid, string memory newMetadataURI) internal {
        Schema.Member storage target = $.members[mid];
        if (msg.sender != target.addr) revert OnlyYouCanModifyYourOwnProfile();
        target.metadataURI = newMetadataURI;
        emit MemberProfileUpdated(newMetadataURI);
    }

    function isMember(Schema.Members storage $, address _checkAddress) internal view returns(bool result) {
        for (uint i; i < $.members.length; ++i) {
            if ($.members[i].addr == _checkAddress) {
                result = true;
                break;
            }
        }
    }
}
