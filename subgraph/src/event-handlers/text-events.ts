import {
	TextCreated,
	TextCreatedByProposal,
	TextDeleted,
	TextDeletedByProposal,
	TextUpdated,
	TextUpdatedByProposal,
} from "../../generated/TextDAO/TextDAOEvents";
import { TextContents } from "../../generated/templates";
import { genTextContentsId } from "../utils/entity-id-provider";
import { removeTextEntity } from "../utils/entity-provider";
import { createNewText, loadText } from "../utils/entity-provider";

/**
 * Handles the TextCreated event by creating a new Text entity.
 * This event is triggered when a text is created directly.
 * @param event The TextCreated event containing the event data
 */
export function handleTextCreated(event: TextCreated): void {
	const text = createNewText(event.params.textId);
	text.contents = genTextContentsId(event.params.metadataCid);
	text.cid = event.params.metadataCid;
	TextContents.create(event.params.metadataCid);
	text.save();
}

/**
 * Handles the TextCreatedByProposal event by creating a new Text entity.
 * This event is triggered when a text is created through a proposal.
 * @param event The TextCreatedByProposal event containing the event data
 */
export function handleTextCreatedByProposal(
	event: TextCreatedByProposal,
): void {
	const text = createNewText(event.params.textId);
	text.contents = genTextContentsId(event.params.metadataCid);
	text.cid = event.params.metadataCid;
	TextContents.create(event.params.metadataCid);
	text.save();
}

/**
 * Handles the TextUpdated event by updating an existing Text entity.
 * This event is triggered when a text is updated directly.
 * @param event The TextUpdated event containing the event data
 */
export function handleTextUpdated(event: TextUpdated): void {
	const text = loadText(event.params.textId);
	text.contents = genTextContentsId(event.params.newMetadataCid);
	text.cid = event.params.newMetadataCid;
	TextContents.create(event.params.newMetadataCid);
	text.save();
}

/**
 * Handles the TextUpdatedByProposal event by updating an existing Text entity.
 * This event is triggered when a text is updated through a proposal.
 * @param event The TextUpdatedByProposal event containing the event data
 */
export function handleTextUpdatedByProposal(
	event: TextUpdatedByProposal,
): void {
	const text = loadText(event.params.textId);
	text.contents = genTextContentsId(event.params.newMetadataCid);
	text.cid = event.params.newMetadataCid;
	TextContents.create(event.params.newMetadataCid);
	text.save();
}

/**
 * Handles the TextDeleted event by removing the corresponding Text entity if it exists.
 * This event is triggered when a text is deleted directly.
 * @param event The TextDeleted event containing the event data
 */
export function handleTextDeleted(event: TextDeleted): void {
	removeTextEntity(event.params.textId);
}

/**
 * Handles the TextDeletedByProposal event by removing the corresponding Text entity if it exists.
 * This event is triggered when a text is deleted through a proposal.
 * @param event The TextDeletedByProposal event containing the event data
 */
export function handleTextDeletedByProposal(
	event: TextDeletedByProposal,
): void {
	removeTextEntity(event.params.textId);
}
