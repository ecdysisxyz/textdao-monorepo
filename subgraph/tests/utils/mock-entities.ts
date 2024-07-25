import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import { Proposal, Command, Action } from "../../generated/schema";
import {
    genProposalId,
    genCommandId,
    genActionId,
} from "../../src/utils/entity-id-provider";

export function createMockProposalEntity(
    pid: BigInt,
    fullyExecuted: boolean
): void {
    let proposal = new Proposal(genProposalId(pid));
    proposal.fullyExecuted = fullyExecuted;
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
    status: string
): void {
    let action = new Action(genActionId(pid, commandId, actionId));
    action.command = genCommandId(pid, commandId);
    action.func = "mockFunction()";
    action.abiParams = Bytes.fromHexString("0x");
    action.status = status;
    action.save();
}
