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

export function handleVoted(event: VotedEvent): void {
    let vote = createOrLoadVote(event.params.pid, event.params.rep);
    vote.proposal = genProposalId(event.params.pid);
    vote.rep = event.params.rep;
    vote.rankedHeaderIds = event.params.vote.rankedHeaderIds;
    vote.rankedCommandIds = event.params.vote.rankedCommandIds;
    vote.save();
}
