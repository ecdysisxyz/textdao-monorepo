import {
	MemberAdded,
	MemberAddedByProposal,
	MemberUpdated,
	MemberUpdatedByProposal,
} from "../../generated/TextDAO/TextDAOEvents";
import { saveMemberMetadata } from "../file-data-handlers/member-metadata";
import { createNewMember, loadMember } from "../utils/entity-provider";

/**
 * Handles the MemberAdded event by creating a new Member entity.
 * This event is triggered when a member is added directly.
 * @param event The MemberAdded event containing the event data
 */
export function handleMemberAdded(event: MemberAdded): void {
	const member = createNewMember(event.params.memberId);
	member.addr = event.params.addr;
	member.save();
	saveMemberMetadata(event.params.metadataCid, member);
}

/**
 * Handles the MemberAddedByProposal event by creating a new Member entity.
 * This event is triggered when a member is added through a proposal.
 * @param event The MemberAddedByProposal event containing the event data
 */
export function handleMemberAddedByProposal(
	event: MemberAddedByProposal,
): void {
	const member = createNewMember(event.params.memberId);
	member.addr = event.params.addr;
	member.save();
	saveMemberMetadata(event.params.metadataCid, member);
}

/**
 * Handles the MemberUpdated event by updating an existing Member entity.
 * This event is triggered when a member's information is updated directly.
 * @param event The MemberUpdated event containing the event data
 */
export function handleMemberUpdated(event: MemberUpdated): void {
	const member = loadMember(event.params.memberId);
	member.addr = event.params.addr;
	member.save();
	saveMemberMetadata(event.params.metadataCid, member);
}

/**
 * Handles the MemberUpdatedByProposal event by updating an existing Member entity.
 * This event is triggered when a member's information is updated through a proposal.
 * @param event The MemberUpdatedByProposal event containing the event data
 */
export function handleMemberUpdatedByProposal(
	event: MemberUpdatedByProposal,
): void {
	const member = loadMember(event.params.memberId);
	member.addr = event.params.addr;
	member.save();
	saveMemberMetadata(event.params.metadataCid, member);
}
