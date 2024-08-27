import { RepresentativesAssigned } from "../../generated/TextDAO/TextDAOEvents";
import { loadOrCreateProposal } from "../utils/entity-provider";
import { formatAddressArrayToBytesArray } from "../utils/type-formatter";

/**
 * Handles the RepresentativesAssigned event by updating or creating the Proposal entity with assigned representatives.
 * This function ensures that:
 * 1. The Proposal entity is created if it doesn't exist.
 * 2. The reps field is updated with the newly assigned representatives.
 * 3. Any unexpected behavior is logged for easier debugging.
 *
 * @param event The RepresentativesAssigned event containing the event data
 */
export function handleRepresentativesAssigned(
    event: RepresentativesAssigned
): void {
    const proposal = loadOrCreateProposal(event.params.pid);

    proposal.reps = formatAddressArrayToBytesArray(event.params.reps);

    proposal.save();

    // log.info("Representatives assigned to Proposal with ID: {}", [
    //     proposalEntityId,
    // ]);
}
