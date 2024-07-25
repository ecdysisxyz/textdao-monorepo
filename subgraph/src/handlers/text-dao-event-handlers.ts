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

export function handleCommandCreated(event: CommandCreatedEvent): void {
    let command = createOrLoadCommand(event.params.pid, event.params.commandId);
    command.proposal = genProposalId(event.params.pid);
    let actions = event.params.actions;
    for (let i = 0; i < actions.length; i++) {
        let action = createOrLoadAction(
            event.params.pid,
            event.params.commandId,
            i
        );
        action.command = genCommandId(event.params.pid, event.params.commandId);
        action.func = actions[i].funcSig;
        action.abiParams = actions[i].abiParams;
        action.status = "Proposed";
        action.save();
    }
    command.save();
}

export function handleProposed(event: ProposedEvent): void {
    let proposal = createOrLoadProposal(event.params.pid);
    proposal.proposer = event.params.proposer;
    proposal.createdAt = event.params.createdAt;
    proposal.expirationTime = event.params.expirationTime;
    proposal.save();
}

export function handleRepresentativesAssigned(
    event: RepresentativesAssignedEvent
): void {
    let proposal = createOrLoadProposal(event.params.pid);
    let reps = event.params.reps;
    let repsBytesArray: Array<Bytes> = [];
    for (let i = 0; i < reps.length; i++) {
        repsBytesArray.push(reps[i] as Bytes);
    }
    proposal.reps = repsBytesArray;
    proposal.save();
}

export function handleVRFRequested(event: VRFRequestedEvent): void {
    let proposal = createOrLoadProposal(event.params.pid);
    proposal.vrfRequestId = event.params.requestId;
    proposal.save();
}

export function handleVoted(event: VotedEvent): void {
    let vote = createOrLoadVote(event.params.pid, event.params.rep);
    vote.proposal = genProposalId(event.params.pid);
    vote.rep = event.params.rep;
    vote.rankedHeaderIds = event.params.vote.rankedHeaderIds;
    vote.rankedCommandIds = event.params.vote.rankedCommandIds;
    vote.save();
}

export function handleProposalSnapped(event: ProposalSnappedEvent): void {
    let proposal = createOrLoadProposal(event.params.pid);
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

export function handleTextCreated(event: TextCreatedEvent): void {
    let text = createOrLoadText(event.params.textId);
    text.metadataURI = event.params.metadataURI;
    text.save();
}

export function handleTextUpdated(event: TextUpdatedEvent): void {
    let text = createOrLoadText(event.params.textId);
    text.metadataURI = event.params.newMetadataURI;
    text.save();
}

export function handleTextDeleted(event: TextDeletedEvent): void {
    store.remove("Text", genTextId(event.params.textId));
}
