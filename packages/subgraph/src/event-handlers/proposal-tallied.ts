import { ProposalTallied, ProposalTalliedWithTie } from "../../generated/TextDAO/TextDAOEvents";
import { genCommandIds, genHeaderIds } from "../utils/entity-id-provider";
import { loadProposal } from "../utils/entity-provider";

/**
 * Handles the ProposalTallied event by updating the Proposal entity.
 * This function ensures that:
 * 1. The Proposal entity is created if it doesn't already exist.
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
 * 1. The Proposal entity is created if it doesn't already exist.
 * 2. The expirationTime, top3Headers, and top3Commands fields are updated.
 *
 * @param event The ProposalTalliedWithTie event containing the event data
 */
export function handleProposalTalliedWithTie(event: ProposalTalliedWithTie): void {
  const proposal = loadProposal(event.params.pid);
  proposal.top3Headers = genHeaderIds(event.params.pid, event.params.topHeaderIds);
  proposal.top3Commands = genCommandIds(event.params.pid, event.params.topCommandIds);
  proposal.expirationTime = event.params.extendedExpirationTime;
  proposal.save();
}
