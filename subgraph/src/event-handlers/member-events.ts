import {
	MemberAdded,
	MemberAddedByProposal,
	MemberRemoved,
	MemberRemovedByProposal,
	MemberUpdated,
	MemberUpdatedByProposal,
} from "../../generated/TextDAO/TextDAOEvents";
import { saveMemberMetadata } from "../file-data-handlers/member-metadata";
import {
	createNewMember,
	loadMember,
	removeMemberEntity,
} from "../utils/entity-provider";

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

/**
 * Handles the MemberRemoved event by removing the corresponding Member entity if it exists.
 * This event is triggered when a member is removed directly.
 * @param event The MemberRemoved event containing the event data
 */
export function handleMemberRemoved(event: MemberRemoved): void {
	removeMemberEntity(event.params.memberId);
}

/**
 * Handles the MemberRemovedByProposal event by removing the corresponding Member entity if it exists.
 * This event is triggered when a member is removed through a proposal.
 * @param event The MemberRemovedByProposal event containing the event data
 */
export function handleMemberRemovedByProposal(
	event: MemberRemovedByProposal,
): void {
	removeMemberEntity(event.params.memberId);
}
