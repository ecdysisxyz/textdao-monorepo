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
