import { log } from "@graphprotocol/graph-ts";
import { Proposal } from "../../generated/schema";
import { ProposalSnapped } from "../../generated/TextDAO/TextDAOEvents";
import {
    genHeaderIds,
    genCommandIds,
    genProposalId,
} from "../utils/entity-id-provider";

/**
 * Handles the ProposalSnapped event by updating the Proposal entity with top3 headers and commands.
 * This function ensures that:
 * 1. The corresponding Proposal entity exists before updating.
 * 2. The top3Headers and top3Commands fields of the Proposal are updated.
 *
 * @param event - The ProposalSnapped event containing the event data
 */
export function handleProposalSnapped(event: ProposalSnapped): void {
    let proposalEntityId = genProposalId(event.params.pid);
    let proposal = Proposal.load(proposalEntityId);
    if (!proposal) {
        log.warning(
            "Proposal not found for ProposalSnapped event. Proposal ID: {}",
            [proposalEntityId]
        );
        return;
    }

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
