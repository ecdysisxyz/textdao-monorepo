import { ProposalTallied, ProposalTalliedWithTie } from "../../generated/TextDAO/TextDAOEvents";
import { createNewTopCommands, createNewTopHeaders, loadProposal } from "../utils/entity-provider";

/**
 * Handles the ProposalTallied event by updating the Proposal entity.
 * This function ensures that:
 * 1. The Proposal entity is loaded.
 * 2. The approvedHeaderId and approvedCommandId fields are updated.
 *
 * @param event The ProposalTallied event containing the event data
 */
export function handleProposalTallied(event: ProposalTallied): void {
  const proposal = loadProposal(event.params.pid);
  proposal.approvedHeaderId = event.params.approvedHeaderId;
  proposal.approvedCommandId = event.params.approvedCommandId;
  proposal.save();
}

/**
 * Handles the ProposalTalliedWithTie event by updating the Proposal entity.
 * This function ensures that:
 * 1. The Proposal entity is loaded.
 * 2. The expirationTime is updated.
 * 3. New TopHeader and TopCommand entities are created and linked to the Proposal.
 *
 * @param event The ProposalTalliedWithTie event containing the event data
 */
export function handleProposalTalliedWithTie(event: ProposalTalliedWithTie): void {
  const proposal = loadProposal(event.params.pid);
  proposal.expirationTime = event.params.extendedExpirationTime;
  proposal.topHeaders = createNewTopHeaders(event.params.pid, event.params.epoch, event.params.topHeaderIds);
  proposal.topCommands = createNewTopCommands(event.params.pid, event.params.epoch, event.params.topCommandIds);
  proposal.save();
}
