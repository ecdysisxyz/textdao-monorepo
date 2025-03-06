import { ProposalSnapped } from "../../generated/TextDAO/TextDAOEvents";
import { createNewTopCommands, createNewTopHeaders, loadProposal } from "../utils/entity-provider";
import { pushToBigIntArray } from "../utils/type-formatter";

/**
 * Handles the ProposalSnapped event by updating the Proposal entity with top headers and commands.
 * This function ensures that:
 * 1. The corresponding Proposal entity exists before updating.
 * 2. New TopHeader and TopCommand entities are created for the current snapshot.
 * 3. The Proposal's topHeaders and topCommands fields are updated with references to the new entities.
 * 4. The snappedEpoch field is appended with the new epoch.
 * 5. The snappedTimes field is appended with the block timestamp of the event.
 *
 * @param event - The ProposalSnapped event containing the event data
 */
export function handleProposalSnapped(event: ProposalSnapped): void {
  const proposal = loadProposal(event.params.pid);

  // Append new epoch and timestamp to the arrays
  proposal.snappedEpoch = pushToBigIntArray(proposal.snappedEpoch, event.params.epoch);
  proposal.snappedTimes = pushToBigIntArray(proposal.snappedTimes, event.block.timestamp);

  // Create new TopHeader and TopCommand entities and get their IDs
  const newTopHeaderIds = createNewTopHeaders(event.params.pid, event.params.epoch, event.params.topHeaderIds);
  const newTopCommandIds = createNewTopCommands(event.params.pid, event.params.epoch, event.params.topCommandIds);

  // Update the Proposal's topHeaders and topCommands with the new entity references
  proposal.topHeaders = newTopHeaderIds;
  proposal.topCommands = newTopCommandIds;

  proposal.save();
}
