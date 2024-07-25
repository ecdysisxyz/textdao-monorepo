import { log } from "@graphprotocol/graph-ts";
import {
    ProposalTallied,
    ProposalTalliedWithTie,
} from "../../generated/TextDAO/TextDAOEvents";
import { Proposal } from "../../generated/schema";
import {
    genProposalId,
    genHeaderIds,
    genCommandIds,
} from "../utils/entity-id-provider";

/**
 * Handles the ProposalTallied event by updating the Proposal entity.
 * This function ensures that:
 * 1. The Proposal entity is created if it doesn't already exist.
 * 2. The approvedHeaderId and approvedCommandId fields are updated.
 *
 * @param event The ProposalTallied event containing the event data
 */
export function handleProposalTallied(event: ProposalTallied): void {
    let proposalEntityId = genProposalId(event.params.pid);
    let proposal = Proposal.load(proposalEntityId);
    if (!proposal) {
        log.warning(
            "Proposal not found for ProposalTallied event. Proposal ID: {}",
            [proposalEntityId]
        );
        return;
    }
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
export function handleProposalTalliedWithTie(
    event: ProposalTalliedWithTie
): void {
    let proposalEntityId = genProposalId(event.params.pid);
    let proposal = Proposal.load(proposalEntityId);
    if (!proposal) {
        log.warning(
            "Proposal not found for ProposalTalliedWithTie event. Proposal ID: {}",
            [proposalEntityId]
        );
        return;
    }
    proposal.expirationTime = event.params.extendedExpirationTime;
    proposal.top3Headers = genHeaderIds(
        event.params.pid,
        event.params.approvedHeaderIds
    );
    proposal.top3Commands = genCommandIds(
        event.params.pid,
        event.params.approvedCommandIds
    );
    proposal.save();
}
