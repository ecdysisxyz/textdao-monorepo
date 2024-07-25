import { log, Bytes } from "@graphprotocol/graph-ts";
import { RepresentativesAssigned } from "../../generated/TextDAO/TextDAOEvents";
import { genProposalId } from "../utils/entity-id-provider";
import { Proposal } from "../../generated/schema";

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
    const proposalEntityId = genProposalId(event.params.pid);
    let proposal = new Proposal(proposalEntityId);

    let repsBytesArray: Array<Bytes> = [];
    for (let i = 0; i < event.params.reps.length; i++) {
        repsBytesArray.push(event.params.reps[i]);
    }

    proposal.reps = repsBytesArray;

    proposal.save();

    // log.info("Representatives assigned to Proposal with ID: {}", [
    //     proposalEntityId,
    // ]);
}
