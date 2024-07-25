import { Bytes, store } from "@graphprotocol/graph-ts";
import {
    HeaderCreated as HeaderCreatedEvent,
    CommandCreated as CommandCreatedEvent,
    Proposed as ProposedEvent,
    ProposalExecuted as ProposalExecutedEvent,
    ProposalSnapped as ProposalSnappedEvent,
    ProposalTallied as ProposalTalliedEvent,
    ProposalTalliedWithTie as ProposalTalliedWithTieEvent,
    RepresentativesAssigned as RepresentativesAssignedEvent,
    TextCreated as TextCreatedEvent,
    TextDeleted as TextDeletedEvent,
    TextUpdated as TextUpdatedEvent,
    VRFRequested as VRFRequestedEvent,
    Voted as VotedEvent,
} from "../../generated/TextDAO/TextDAOEvents";
import {
    genCommandId,
    genCommandIds,
    genHeaderId,
    genHeaderIds,
    genProposalId,
    genTextId,
} from "../utils/entity-id-provider";
import {
    createHeader,
    createOrLoadAction,
    createOrLoadCommand,
    createOrLoadHeader,
    createOrLoadProposal,
    createOrLoadText,
    createOrLoadVote,
} from "../utils/entity-provider";
import { Header, Proposal } from "../../generated/schema";

export function handleProposalTallied(event: ProposalTalliedEvent): void {
    let proposal = createOrLoadProposal(event.params.pid);
    proposal.approvedHeaderId = event.params.approvedHeaderId;
    proposal.approvedCommandId = event.params.approvedCommandId;
    proposal.save();
}

export function handleProposalTalliedWithTie(
    event: ProposalTalliedWithTieEvent
): void {
    let proposal = createOrLoadProposal(event.params.pid);
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
