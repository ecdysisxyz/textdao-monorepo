import {
    TextCreated,
    TextDeleted,
    TextUpdated,
} from "../../generated/TextDAO/TextDAOEvents";
import {
    createNewText,
    loadText,
    removeTextEntity,
} from "../utils/entity-provider";

/**
 * Handles the TextCreated event by creating a new Text entity or updating an existing one.
 * @param event The TextCreated event containing the event data
 */
export function handleTextCreated(event: TextCreated): void {
    const text = createNewText(event.params.textId);
    text.metadataURI = event.params.metadataURI;
    text.save();
}

/**
 * Handles the TextUpdated event by updating an existing Text entity.
 * @param event The TextUpdated event containing the event data
 */
export function handleTextUpdated(event: TextUpdated): void {
    const text = loadText(event.params.textId);
    text.metadataURI = event.params.newMetadataURI;
    text.save();
}

/**
 * Handles the TextDeleted event by removing the corresponding Text entity if it exists.
 * @param event The TextDeleted event containing the event data
 */
export function handleTextDeleted(event: TextDeleted): void {
    removeTextEntity(event.params.textId);
}
