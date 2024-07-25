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

export function handleProposalExecuted(event: ProposalExecutedEvent): void {
    let proposal = createOrLoadProposal(event.params.pid);
    proposal.fullyExecuted = true;
    let actions = createOrLoadCommand(
        event.params.pid,
        event.params.approvedCommandId
    ).actions.load();
    for (let i = 0; i < actions.length; i++) {
        let action = actions[i];
        action.status = "Executed";
        action.save();
    }
    proposal.save();
}
