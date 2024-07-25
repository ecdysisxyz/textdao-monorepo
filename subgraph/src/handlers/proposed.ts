import { log } from "@graphprotocol/graph-ts";
import { Proposed } from "../../generated/TextDAO/TextDAOEvents";
import { genProposalId } from "../utils/entity-id-provider";
import { Proposal } from "../../generated/schema";

/**
 * Handles the Proposed event by creating or updating the Proposal entity.
 * This function ensures that:
 * 1. A new Proposal entity is created if it doesn't already exist.
 * 2. The proposer, createdAt, and expirationTime fields are updated.
 * 3. Any unexpected behavior is logged for easier debugging.
 *
 * @param event The Proposed event containing the event data
 */
export function handleProposed(event: Proposed): void {
    const proposalEntityId = genProposalId(event.params.pid);
    let proposal = Proposal.load(proposalEntityId);
    if (proposal) {
        log.warning("Proposal already exists with ID: {}.", [proposalEntityId]);
        return;
    }
    proposal = new Proposal(proposalEntityId);

    proposal.proposer = event.params.proposer;
    proposal.createdAt = event.params.createdAt;
    proposal.expirationTime = event.params.expirationTime;
    proposal.save();

    // log.info("Proposal created/updated with ID: {}", [proposalEntityId]);
}
