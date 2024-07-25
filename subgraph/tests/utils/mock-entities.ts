import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import { Proposal, Command, Action } from "../../generated/schema";
import {
    genProposalId,
    genCommandId,
    genActionId,
} from "../../src/utils/entity-id-provider";

export function createMockProposalEntity(
    pid: BigInt,
    fullyExecuted: boolean = false,
    top3Headers: string[] | null = null,
    top3Commands: string[] | null = null
): void {
    let proposal = new Proposal(genProposalId(pid));
    proposal.fullyExecuted = fullyExecuted;
    if (top3Headers !== null) {
        proposal.top3Headers = top3Headers;
    }
    if (top3Commands !== null) {
        proposal.top3Commands = top3Commands;
    }
    proposal.save();
}

export function createMockCommandEntity(pid: BigInt, commandId: BigInt): void {
    let command = new Command(genCommandId(pid, commandId));
    command.proposal = genProposalId(pid);
    command.save();
}

export function createMockActionEntity(
    pid: BigInt,
    commandId: BigInt,
    actionId: i32,
    status: string = "Proposed",
    func: string = "mockFunction()",
    abiParams: Bytes = Bytes.fromHexString("0x")
): void {
    let action = new Action(genActionId(pid, commandId, actionId));
    action.command = genCommandId(pid, commandId);
    action.status = status;
    action.func = func;
    action.abiParams = abiParams;
    action.save();
}
