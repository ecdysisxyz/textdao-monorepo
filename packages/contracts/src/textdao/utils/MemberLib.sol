// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";

/**
 * @title MemberLib v0.1.0
 */
library MemberLib {
    function addMember(Schema.Members storage $, Schema.Member memory newMember) internal returns(Schema.Member storage) {
        uint _memberId = Storage.Members().members.length;
        Schema.Member storage member = $.members.push() = newMember;
        emit TextDAOEvents.MemberAdded(_memberId, newMember.addr, newMember.metadataCid);
        return member;
    }

    function addMembers(Schema.Members storage $, Schema.Member[] memory newMembers) internal returns(Schema.Members storage) {
        for (uint i; i < newMembers.length; ++i) {
            addMember($, newMembers[i]);
        }
        return $;
    }

    function updateMemberInfo(Schema.Members storage $, uint mid, string memory newMetadataCid) internal {
        Schema.Member storage target = $.members[mid];
        if (msg.sender != target.addr) revert("Only you can modify your own profile");
        target.metadataCid = newMetadataCid;
        emit TextDAOEvents.MemberUpdated(mid, target.addr, newMetadataCid);
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
