import { ProposalSnapped } from "../../generated/TextDAO/TextDAOEvents";
import { genHeaderIds, genCommandIds } from "../utils/entity-id-provider";
import { loadProposal } from "../utils/entity-provider";

/**
 * Handles the ProposalSnapped event by updating the Proposal entity with top3 headers and commands.
 * This function ensures that:
 * 1. The corresponding Proposal entity exists before updating.
 * 2. The top3Headers and top3Commands fields of the Proposal are updated.
 *
 * @param event - The ProposalSnapped event containing the event data
 */
export function handleProposalSnapped(event: ProposalSnapped): void {
    const proposal = loadProposal(event.params.pid);

    proposal.top3Headers = genHeaderIds(
        event.params.pid,
        event.params.top3HeaderIds
    );
    proposal.top3Commands = genCommandIds(
        event.params.pid,
        event.params.top3CommandIds
    );

    proposal.save();
}
