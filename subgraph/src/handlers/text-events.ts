import { store } from "@graphprotocol/graph-ts";
import {
    TextCreated,
    TextDeleted,
    TextUpdated,
} from "../../generated/TextDAO/TextDAOEvents";
import { genTextId } from "../utils/entity-id-provider";
import { Text } from "../../generated/schema";

/**
 * Handles the TextCreated event by creating a new Text entity or updating an existing one.
 * @param event The TextCreated event containing the event data
 */
export function handleTextCreated(event: TextCreated): void {
    let text = new Text(genTextId(event.params.textId));
    text.metadataURI = event.params.metadataURI;
    text.save();
}

/**
 * Handles the TextUpdated event by updating an existing Text entity.
 * @param event The TextUpdated event containing the event data
 */
export function handleTextUpdated(event: TextUpdated): void {
    let textId = genTextId(event.params.textId);
    let text = Text.load(textId);
    if (text == null) {
        text = new Text(textId);
    }
    text.metadataURI = event.params.newMetadataURI;
    text.save();
}

/**
 * Handles the TextDeleted event by removing the corresponding Text entity if it exists.
 * @param event The TextDeleted event containing the event data
 */
export function handleTextDeleted(event: TextDeleted): void {
    let textId = genTextId(event.params.textId);
    let text = Text.load(textId);
    if (text != null) {
        store.remove("Text", textId);
    }
}
