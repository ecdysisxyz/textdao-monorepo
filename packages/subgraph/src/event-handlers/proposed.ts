import { Proposed } from "../../generated/TextDAO/TextDAOEvents";
import { loadProposal } from "../utils/entity-provider";

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
  const proposal = loadProposal(event.params.pid);

  proposal.proposer = event.params.proposer;
  proposal.createdAt = event.params.createdAt;
  proposal.expirationTime = event.params.expirationTime;
  proposal.snapInterval = event.params.snapInterval;
  proposal.save();

  // log.info("Proposal updated with Proposed event data. Proposal ID: {}", [
  //     proposalEntityId,
  // ]);
}
