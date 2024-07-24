import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import {
    Action,
    Command,
    Header,
    Proposal,
    Text,
    Vote,
} from "../generated/schema";
import {
    genActionId,
    genCommandId,
    genHeaderId,
    genProposalId,
    genTextId,
    genVoteId,
} from "./entity-id-provider";

export function createOrLoadProposal(pid: BigInt): Proposal {
    const id = genProposalId(pid);
    let proposal = Proposal.load(id);
    if (proposal == null) {
        proposal = new Proposal(id);
    }
    return proposal;
}

export function createOrLoadHeader(pid: BigInt, headerId: BigInt): Header {
    const id = genHeaderId(pid, headerId);
    let header = Header.load(id);
    if (header == null) {
        header = new Header(id);
    }
    return header;
}

export function createOrLoadCommand(pid: BigInt, commandId: BigInt): Command {
    const id = genCommandId(pid, commandId);
    let command = Command.load(id);
    if (command == null) {
        command = new Command(id);
    }
    return command;
}

export function createOrLoadVote(pid: BigInt, rep: Bytes): Vote {
    const id = genVoteId(pid, rep);
    let vote = Vote.load(id);
    if (vote == null) {
        vote = new Vote(id);
    }
    return vote;
}

export function createOrLoadAction(
    pid: BigInt,
    commandId: BigInt,
    actionId: number
): Action {
    const id = genActionId(pid, commandId, actionId);
    let action = Action.load(id);
    if (action == null) {
        action = new Action(id);
    }
    return action;
}

export function createOrLoadText(textId: BigInt): Text {
    const id = genTextId(textId);
    let text = Text.load(id);
    if (text == null) {
        text = new Text(id);
    }
    return text;
}
