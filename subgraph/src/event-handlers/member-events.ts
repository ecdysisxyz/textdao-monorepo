import {
    MemberAdded,
    MemberUpdated,
} from "../../generated/TextDAO/TextDAOEvents";
import { saveMemberMetadata } from "../file-data-handlers/member-metadata";
import { createNewMember, loadMember } from "../utils/entity-provider";

/**
 * Handles the MemberAdded event by creating a new Member entity.
 * @param event The MemberAdded event containing the event data
 */
export function handleMemberAdded(event: MemberAdded): void {
    const member = createNewMember(event.params.memberId);
    member.addr = event.params.addr;
    member.save();
    saveMemberMetadata(event.params.metadataCid, member);
}

/**
 * Handles the MemberUpdated event by updating an existing Member entity.
 * @param event The MemberUpdated event containing the event data
 */
export function handleMemberUpdated(event: MemberUpdated): void {
    const member = loadMember(event.params.memberId);
    member.addr = event.params.addr;
    member.save();
    saveMemberMetadata(event.params.metadataCid, member);
}
