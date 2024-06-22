import { newMockEvent } from "matchstick-as";
import { ethereum, Bytes, BigInt } from "@graphprotocol/graph-ts";
import { HeaderProposed } from "../generated/Propose/Propose";

export function createHeaderProposed(
  id: i32,
  pid: i32,
  currentScore: i32,
  metadataURIHex: string,
  tagId1: i32,
  tagId2: i32
): HeaderProposed {
  let headerProposed = changetype<HeaderProposed>(newMockEvent());

  headerProposed.parameters = new Array();
  headerProposed.parameters.push(
    new ethereum.EventParam(
      "pid",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(pid))
    )
  );
  let header = new ethereum.Tuple();
  header.push(ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(id)));
  header.push(ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(currentScore)));
  header.push(ethereum.Value.fromBytes(Bytes.fromHexString(metadataURIHex)));
  header.push(
    ethereum.Value.fromArray([
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(tagId1)),
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(tagId2)),
    ])
  );
  headerProposed.parameters.push(
    new ethereum.EventParam("header", ethereum.Value.fromTuple(header))
  );

  return headerProposed;
}
