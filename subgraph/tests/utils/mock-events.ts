import { newMockEvent } from "matchstick-as";
import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts";
import {
    HeaderCreated,
    CommandCreated,
    Proposed,
    RepresentativesAssigned,
    VRFRequested,
    Voted,
    ProposalTalliedWithTie,
    ProposalTallied,
    ProposalSnapped,
    ProposalExecuted,
    TextCreated,
    TextUpdated,
    TextDeleted,
    Initialized,
} from "../../generated/TextDAO/TextDAOEvents";
import { Action, Vote } from "../../src/utils/schema-types";

/**
 * Creates a mock HeaderCreated event
 * @param pid - Proposal ID
 * @param header - Header ID
 * @param metadataURI - Metadata URI for the header
 * @returns MockEvent of type HeaderCreated
 */
export function createMockHeaderCreatedEvent(
    pid: BigInt,
    headerId: BigInt,
    metadataURI: string
): HeaderCreated {
    let event = changetype<HeaderCreated>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam(
            "headerId",
            ethereum.Value.fromUnsignedBigInt(headerId)
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "metadataURI",
            ethereum.Value.fromString(metadataURI)
        )
    );
    return event;
}

/**
 * Creates a mock CommandCreated event
 * @param pid - Proposal ID
 * @param commandId - Command ID
 * @param actions - Array of actions (each containing funcSig and abiParams)
 * @returns MockEvent of type CommandCreated
 */
export function createMockCommandCreatedEvent(
    pid: BigInt,
    commandId: BigInt,
    actions: Array<Action>
): CommandCreated {
    let event = changetype<CommandCreated>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam(
            "commandId",
            ethereum.Value.fromUnsignedBigInt(commandId)
        )
    );

    let actionsArray = new Array<ethereum.Tuple>();
    for (let i = 0; i < actions.length; i++) {
        let actionTuple = new ethereum.Tuple();
        actionTuple.push(ethereum.Value.fromString(actions[i].funcSig));
        actionTuple.push(ethereum.Value.fromBytes(actions[i].abiParams));
        actionsArray.push(actionTuple);
    }
    event.parameters.push(
        new ethereum.EventParam(
            "actions",
            ethereum.Value.fromTupleArray(actionsArray)
        )
    );

    return event;
}

/**
 * Creates a mock Proposed event
 * @param pid - Proposal ID
 * @param proposer - Address of the proposer
 * @param createdAt - Timestamp of proposal creation
 * @param expirationTime - Expiration timestamp of the proposal
 * @returns MockEvent of type Proposed
 */
export function createMockProposedEvent(
    pid: BigInt,
    proposer: Address,
    createdAt: BigInt,
    expirationTime: BigInt
): Proposed {
    let event = changetype<Proposed>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam(
            "proposer",
            ethereum.Value.fromAddress(proposer)
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "createdAt",
            ethereum.Value.fromUnsignedBigInt(createdAt)
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "expirationTime",
            ethereum.Value.fromUnsignedBigInt(expirationTime)
        )
    );
    return event;
}

/**
 * Creates a mock RepresentativesAssigned event
 * @param pid - Proposal ID
 * @param reps - Array of representative addresses
 * @returns MockEvent of type RepresentativesAssigned
 */
export function createMockRepresentativesAssignedEvent(
    pid: BigInt,
    reps: Address[]
): RepresentativesAssigned {
    let event = changetype<RepresentativesAssigned>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam("reps", ethereum.Value.fromAddressArray(reps))
    );
    return event;
}

/**
 * Creates a mock VRFRequested event
 * @param pid - Proposal ID
 * @param requestId - VRF request ID
 * @returns MockEvent of type VRFRequested
 */
export function createMockVRFRequestedEvent(
    pid: BigInt,
    requestId: BigInt
): VRFRequested {
    let event = changetype<VRFRequested>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam(
            "requestId",
            ethereum.Value.fromUnsignedBigInt(requestId)
        )
    );
    return event;
}

/**
 * Creates a mock Voted event
 * @param pid - Proposal ID
 * @param rep - Address of the representative who voted
 * @param vote - Vote structure
 * @returns MockEvent of type Voted
 */
export function createMockVotedEvent(
    pid: BigInt,
    rep: Address,
    vote: Vote
): Voted {
    let event = changetype<Voted>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam("rep", ethereum.Value.fromAddress(rep))
    );

    let voteTuple = new ethereum.Tuple();
    voteTuple.push(
        ethereum.Value.fromUnsignedBigIntArray(vote.rankedHeaderIds)
    );
    voteTuple.push(
        ethereum.Value.fromUnsignedBigIntArray(vote.rankedCommandIds)
    );
    event.parameters.push(
        new ethereum.EventParam("vote", ethereum.Value.fromTuple(voteTuple))
    );

    return event;
}

/**
 * Creates a mock ProposalTalliedWithTie event
 * @param pid - Proposal ID
 * @param topHeaderIds - Array of top header IDs
 * @param topCommandIds - Array of top command IDs
 * @param extendedExpirationTime The unix timestamp
 * @returns MockEvent of type ProposalTalliedWithTie
 */
export function createMockProposalTalliedWithTieEvent(
    pid: BigInt,
    topHeaderIds: BigInt[],
    topCommandIds: BigInt[],
    extendedExpirationTime: BigInt
): ProposalTalliedWithTie {
    let event = changetype<ProposalTalliedWithTie>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam(
            "topHeaderIds",
            ethereum.Value.fromI32Array(
                topHeaderIds.map<i32>((id) => id.toI32())
            )
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "topCommandIds",
            ethereum.Value.fromI32Array(
                topCommandIds.map<i32>((id) => id.toI32())
            )
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "extendedExpirationTime",
            ethereum.Value.fromUnsignedBigInt(extendedExpirationTime)
        )
    );
    return event;
}

/**
 * Creates a mock ProposalTallied event
 * @param pid - Proposal ID
 * @param approvedHeaderId - Approved header ID
 * @param approvedCommandId - Approved command ID
 * @returns MockEvent of type ProposalTallied
 */
export function createMockProposalTalliedEvent(
    pid: BigInt,
    approvedHeaderId: BigInt,
    approvedCommandId: BigInt
): ProposalTallied {
    let event = changetype<ProposalTallied>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam(
            "approvedHeaderId",
            ethereum.Value.fromUnsignedBigInt(approvedHeaderId)
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "approvedCommandId",
            ethereum.Value.fromUnsignedBigInt(approvedCommandId)
        )
    );
    return event;
}

/**
 * Creates a mock ProposalSnapped event
 * @param pid - Proposal ID
 * @param epoch - Snapped epoch timestamp (rounded block.timestamp by interval)
 * @param top3HeaderIds - Array of top 3 header IDs
 * @param top3CommandIds - Array of top 3 command IDs
 * @returns MockEvent of type ProposalSnapped
 */
export function createMockProposalSnappedEvent(
    pid: BigInt,
    epoch: BigInt,
    top3HeaderIds: BigInt[],
    top3CommandIds: BigInt[]
): ProposalSnapped {
    let event = changetype<ProposalSnapped>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam(
            "epoch",
            ethereum.Value.fromUnsignedBigInt(epoch)
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "top3HeaderIds",
            ethereum.Value.fromI32Array(
                top3HeaderIds.map<i32>((id) => id.toI32())
            )
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "top3CommandIds",
            ethereum.Value.fromI32Array(
                top3CommandIds.map<i32>((id) => id.toI32())
            )
        )
    );
    return event;
}

/**
 * Creates a mock ProposalExecuted event
 * @param pid - Proposal ID
 * @param approvedCommandId - Approved command ID
 * @returns MockEvent of type ProposalExecuted
 */
export function createMockProposalExecutedEvent(
    pid: BigInt,
    approvedCommandId: BigInt
): ProposalExecuted {
    let event = changetype<ProposalExecuted>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
    );
    event.parameters.push(
        new ethereum.EventParam(
            "approvedCommandId",
            ethereum.Value.fromUnsignedBigInt(approvedCommandId)
        )
    );
    return event;
}

/**
 * Creates a mock TextCreated event
 * @param textId - Text ID
 * @param metadataURI - Metadata URI for the text
 * @returns MockEvent of type TextCreated
 */
export function createMockTextCreatedEvent(
    textId: BigInt,
    metadataURI: string
): TextCreated {
    let event = changetype<TextCreated>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam(
            "textId",
            ethereum.Value.fromUnsignedBigInt(textId)
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "metadataURI",
            ethereum.Value.fromString(metadataURI)
        )
    );
    return event;
}

/**
 * Creates a mock TextUpdated event
 * @param textId - Text ID
 * @param newMetadataURI - New metadata URI for the text
 * @returns MockEvent of type TextUpdated
 */
export function createMockTextUpdatedEvent(
    textId: BigInt,
    newMetadataURI: string
): TextUpdated {
    let event = changetype<TextUpdated>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam(
            "textId",
            ethereum.Value.fromUnsignedBigInt(textId)
        )
    );
    event.parameters.push(
        new ethereum.EventParam(
            "newMetadataURI",
            ethereum.Value.fromString(newMetadataURI)
        )
    );
    return event;
}

/**
 * Creates a mock TextDeleted event
 * @param textId - Text ID
 * @returns MockEvent of type TextDeleted
 */
export function createMockTextDeletedEvent(textId: BigInt): TextDeleted {
    let event = changetype<TextDeleted>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam(
            "textId",
            ethereum.Value.fromUnsignedBigInt(textId)
        )
    );
    return event;
}

/**
 * Creates a mock Initialized event
 * @param version - Version number
 * @returns MockEvent of type Initialized
 */
export function createMockInitializedEvent(version: BigInt): Initialized {
    let event = changetype<Initialized>(newMockEvent());
    event.parameters = new Array();
    event.parameters.push(
        new ethereum.EventParam(
            "version",
            ethereum.Value.fromUnsignedBigInt(version)
        )
    );
    return event;
}
