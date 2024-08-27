import {
	DeliberationConfigUpdated,
	DeliberationConfigUpdatedByProposal,
} from "../../generated/TextDAO/TextDAOEvents";
import { loadOrCreateDeliberationConfig } from "../utils/entity-provider";

/**
 * Handles the DeliberationConfigUpdated event by updating the DeliberationConfig entity.
 * This event is triggered when the deliberation configuration is updated directly.
 *
 * This function ensures that:
 * 1. The DeliberationConfig entity is created if it doesn't exist.
 * 2. All fields of the DeliberationConfig entity are updated with the new values.
 * 3. The updated entity is saved to the store.
 *
 * @param event The DeliberationConfigUpdated event containing the updated configuration data
 */
export function handleDeliberationConfigUpdated(
	event: DeliberationConfigUpdated,
): void {
	const config = loadOrCreateDeliberationConfig();

	config.expiryDuration = event.params.config.expiryDuration;
	config.snapInterval = event.params.config.snapInterval;
	config.repsNum = event.params.config.repsNum;
	config.quorumScore = event.params.config.quorumScore;

	// Add a timestamp for when the config was last updated
	config.lastUpdated = event.block.timestamp;

	config.save();
}

/**
 * Handles the DeliberationConfigUpdatedByProposal event by updating the DeliberationConfig entity.
 * This event is triggered when the deliberation configuration is updated through a proposal.
 *
 * This function ensures that:
 * 1. The DeliberationConfig entity is created if it doesn't exist.
 * 2. All fields of the DeliberationConfig entity are updated with the new values.
 * 3. The updated entity is saved to the store.
 *
 * @param event The DeliberationConfigUpdatedByProposal event containing the updated configuration data
 */
export function handleDeliberationConfigUpdatedByProposal(
	event: DeliberationConfigUpdatedByProposal,
): void {
	const config = loadOrCreateDeliberationConfig();

	config.expiryDuration = event.params.config.expiryDuration;
	config.snapInterval = event.params.config.snapInterval;
	config.repsNum = event.params.config.repsNum;
	config.quorumScore = event.params.config.quorumScore;

	// Add a timestamp for when the config was last updated
	config.lastUpdated = event.block.timestamp;

	config.save();
}
