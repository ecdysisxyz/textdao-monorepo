import { BigInt, Bytes } from "@graphprotocol/graph-ts";

export function genDeliberationConfigId(): string {
	return "DeliberationConfigID";
}

export function genHeaderId(pid: BigInt, headerId: BigInt): string {
	return "header-" + pid.toString() + "-" + headerId.toString();
}

export function genHeaderContentsId(cid: string): string {
	return cid;
}

export function genHeaderIds(
	pid: BigInt,
	headerIdsBigInt: Array<BigInt>,
): Array<string> {
	const headerIds: Array<string> = [];
	for (let i = 0; i < headerIdsBigInt.length; i++) {
		headerIds.push(genHeaderId(pid, headerIdsBigInt[i]));
	}
	return headerIds;
}

export function genCommandId(pid: BigInt, commandId: BigInt): string {
	return "command-" + pid.toString() + "-" + commandId.toString();
}

export function genCommandIds(
	pid: BigInt,
	commandIdsBigInt: Array<BigInt>,
): Array<string> {
	const commandIds: Array<string> = [];
	for (let i = 0; i < commandIdsBigInt.length; i++) {
		commandIds.push(genCommandId(pid, commandIdsBigInt[i]));
	}
	return commandIds;
}

export function genProposalId(pid: BigInt): string {
	return pid.toString();
}

export function genVoteId(pid: BigInt, rep: Bytes): string {
	return pid.toString() + "-" + rep.toHexString();
}

export function genActionId(
	pid: BigInt,
	commandId: BigInt,
	actionId: number,
): string {
	return (
		pid.toString() + "-" + commandId.toString() + "-" + actionId.toString()
	);
}

export function genTextId(textId: BigInt): string {
	return textId.toString();
}

export function genMemberId(memberId: BigInt): string {
	return memberId.toString();
}
