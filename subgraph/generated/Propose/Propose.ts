// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  ethereum,
  JSONValue,
  TypedMap,
  Entity,
  Bytes,
  Address,
  BigInt,
} from "@graphprotocol/graph-ts";

export class CommandProposed extends ethereum.Event {
  get params(): CommandProposed__Params {
    return new CommandProposed__Params(this);
  }
}

export class CommandProposed__Params {
  _event: CommandProposed;

  constructor(event: CommandProposed) {
    this._event = event;
  }

  get pid(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get cmd(): CommandProposedCmdStruct {
    return changetype<CommandProposedCmdStruct>(
      this._event.parameters[1].value.toTuple()
    );
  }
}

export class CommandProposedCmdStruct extends ethereum.Tuple {
  get id(): BigInt {
    return this[0].toBigInt();
  }

  get actions(): Array<CommandProposedCmdActionsStruct> {
    return this[1].toTupleArray<CommandProposedCmdActionsStruct>();
  }

  get currentScore(): BigInt {
    return this[2].toBigInt();
  }
}

export class CommandProposedCmdActionsStruct extends ethereum.Tuple {
  get func(): string {
    return this[0].toString();
  }

  get abiParams(): Bytes {
    return this[1].toBytes();
  }
}

export class HeaderProposed extends ethereum.Event {
  get params(): HeaderProposed__Params {
    return new HeaderProposed__Params(this);
  }
}

export class HeaderProposed__Params {
  _event: HeaderProposed;

  constructor(event: HeaderProposed) {
    this._event = event;
  }

  get pid(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get header(): HeaderProposedHeaderStruct {
    return changetype<HeaderProposedHeaderStruct>(
      this._event.parameters[1].value.toTuple()
    );
  }
}

export class HeaderProposedHeaderStruct extends ethereum.Tuple {
  get id(): BigInt {
    return this[0].toBigInt();
  }

  get currentScore(): BigInt {
    return this[1].toBigInt();
  }

  get metadataURI(): Bytes {
    return this[2].toBytes();
  }

  get tagIds(): Array<BigInt> {
    return this[3].toBigIntArray();
  }
}

export class Propose__proposeInput_pStruct extends ethereum.Tuple {
  get header(): Propose__proposeInput_pHeaderStruct {
    return changetype<Propose__proposeInput_pHeaderStruct>(this[0].toTuple());
  }

  get cmd(): Propose__proposeInput_pCmdStruct {
    return changetype<Propose__proposeInput_pCmdStruct>(this[1].toTuple());
  }

  get proposalMeta(): Propose__proposeInput_pProposalMetaStruct {
    return changetype<Propose__proposeInput_pProposalMetaStruct>(
      this[2].toTuple()
    );
  }
}

export class Propose__proposeInput_pHeaderStruct extends ethereum.Tuple {
  get id(): BigInt {
    return this[0].toBigInt();
  }

  get currentScore(): BigInt {
    return this[1].toBigInt();
  }

  get metadataURI(): Bytes {
    return this[2].toBytes();
  }

  get tagIds(): Array<BigInt> {
    return this[3].toBigIntArray();
  }
}

export class Propose__proposeInput_pCmdStruct extends ethereum.Tuple {
  get id(): BigInt {
    return this[0].toBigInt();
  }

  get actions(): Array<Propose__proposeInput_pCmdActionsStruct> {
    return this[1].toTupleArray<Propose__proposeInput_pCmdActionsStruct>();
  }

  get currentScore(): BigInt {
    return this[2].toBigInt();
  }
}

export class Propose__proposeInput_pCmdActionsStruct extends ethereum.Tuple {
  get func(): string {
    return this[0].toString();
  }

  get abiParams(): Bytes {
    return this[1].toBytes();
  }
}

export class Propose__proposeInput_pProposalMetaStruct extends ethereum.Tuple {
  get currentScore(): BigInt {
    return this[0].toBigInt();
  }

  get headerRank(): Array<BigInt> {
    return this[1].toBigIntArray();
  }

  get cmdRank(): Array<BigInt> {
    return this[2].toBigIntArray();
  }

  get nextHeaderTallyFrom(): BigInt {
    return this[3].toBigInt();
  }

  get nextCmdTallyFrom(): BigInt {
    return this[4].toBigInt();
  }

  get reps(): Array<Address> {
    return this[5].toAddressArray();
  }

  get nextRepId(): BigInt {
    return this[6].toBigInt();
  }

  get createdAt(): BigInt {
    return this[7].toBigInt();
  }
}

export class Propose extends ethereum.SmartContract {
  static bind(address: Address): Propose {
    return new Propose("Propose", address);
  }

  propose(_p: Propose__proposeInput_pStruct): BigInt {
    let result = super.call(
      "propose",
      "propose(((uint256,uint256,bytes32,uint256[]),(uint256,(string,bytes)[],uint256),(uint256,uint256[],uint256[],uint256,uint256,address[],uint256,uint256))):(uint256)",
      [ethereum.Value.fromTuple(_p)]
    );

    return result[0].toBigInt();
  }

  try_propose(_p: Propose__proposeInput_pStruct): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "propose",
      "propose(((uint256,uint256,bytes32,uint256[]),(uint256,(string,bytes)[],uint256),(uint256,uint256[],uint256[],uint256,uint256,address[],uint256,uint256))):(uint256)",
      [ethereum.Value.fromTuple(_p)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }
}

export class ProposeCall extends ethereum.Call {
  get inputs(): ProposeCall__Inputs {
    return new ProposeCall__Inputs(this);
  }

  get outputs(): ProposeCall__Outputs {
    return new ProposeCall__Outputs(this);
  }
}

export class ProposeCall__Inputs {
  _call: ProposeCall;

  constructor(call: ProposeCall) {
    this._call = call;
  }

  get _p(): ProposeCall_pStruct {
    return changetype<ProposeCall_pStruct>(
      this._call.inputValues[0].value.toTuple()
    );
  }
}

export class ProposeCall__Outputs {
  _call: ProposeCall;

  constructor(call: ProposeCall) {
    this._call = call;
  }

  get proposalId(): BigInt {
    return this._call.outputValues[0].value.toBigInt();
  }
}

export class ProposeCall_pStruct extends ethereum.Tuple {
  get header(): ProposeCall_pHeaderStruct {
    return changetype<ProposeCall_pHeaderStruct>(this[0].toTuple());
  }

  get cmd(): ProposeCall_pCmdStruct {
    return changetype<ProposeCall_pCmdStruct>(this[1].toTuple());
  }

  get proposalMeta(): ProposeCall_pProposalMetaStruct {
    return changetype<ProposeCall_pProposalMetaStruct>(this[2].toTuple());
  }
}

export class ProposeCall_pHeaderStruct extends ethereum.Tuple {
  get id(): BigInt {
    return this[0].toBigInt();
  }

  get currentScore(): BigInt {
    return this[1].toBigInt();
  }

  get metadataURI(): Bytes {
    return this[2].toBytes();
  }

  get tagIds(): Array<BigInt> {
    return this[3].toBigIntArray();
  }
}

export class ProposeCall_pCmdStruct extends ethereum.Tuple {
  get id(): BigInt {
    return this[0].toBigInt();
  }

  get actions(): Array<ProposeCall_pCmdActionsStruct> {
    return this[1].toTupleArray<ProposeCall_pCmdActionsStruct>();
  }

  get currentScore(): BigInt {
    return this[2].toBigInt();
  }
}

export class ProposeCall_pCmdActionsStruct extends ethereum.Tuple {
  get func(): string {
    return this[0].toString();
  }

  get abiParams(): Bytes {
    return this[1].toBytes();
  }
}

export class ProposeCall_pProposalMetaStruct extends ethereum.Tuple {
  get currentScore(): BigInt {
    return this[0].toBigInt();
  }

  get headerRank(): Array<BigInt> {
    return this[1].toBigIntArray();
  }

  get cmdRank(): Array<BigInt> {
    return this[2].toBigIntArray();
  }

  get nextHeaderTallyFrom(): BigInt {
    return this[3].toBigInt();
  }

  get nextCmdTallyFrom(): BigInt {
    return this[4].toBigInt();
  }

  get reps(): Array<Address> {
    return this[5].toAddressArray();
  }

  get nextRepId(): BigInt {
    return this[6].toBigInt();
  }

  get createdAt(): BigInt {
    return this[7].toBigInt();
  }
}
