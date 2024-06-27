// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  TypedMap,
  Entity,
  Value,
  ValueKind,
  store,
  Bytes,
  BigInt,
  BigDecimal,
} from "@graphprotocol/graph-ts";

export class Proposal extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Proposal entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type Proposal must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`,
      );
      store.set("Proposal", id.toString(), this);
    }
  }

  static loadInBlock(id: string): Proposal | null {
    return changetype<Proposal | null>(store.get_in_block("Proposal", id));
  }

  static load(id: string): Proposal | null {
    return changetype<Proposal | null>(store.get("Proposal", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get headers(): HeaderLoader {
    return new HeaderLoader("Proposal", this.get("id")!.toString(), "headers");
  }

  get cmds(): CommandLoader {
    return new CommandLoader("Proposal", this.get("id")!.toString(), "cmds");
  }

  get proposalMeta(): ProposalMetaLoader {
    return new ProposalMetaLoader(
      "Proposal",
      this.get("id")!.toString(),
      "proposalMeta",
    );
  }
}

export class Header extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Header entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type Header must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`,
      );
      store.set("Header", id.toString(), this);
    }
  }

  static loadInBlock(id: string): Header | null {
    return changetype<Header | null>(store.get_in_block("Header", id));
  }

  static load(id: string): Header | null {
    return changetype<Header | null>(store.get("Header", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get proposal(): string {
    let value = this.get("proposal");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set proposal(value: string) {
    this.set("proposal", Value.fromString(value));
  }

  get currentScore(): BigInt {
    let value = this.get("currentScore");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set currentScore(value: BigInt) {
    this.set("currentScore", Value.fromBigInt(value));
  }

  get metadataURI(): Bytes {
    let value = this.get("metadataURI");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBytes();
    }
  }

  set metadataURI(value: Bytes) {
    this.set("metadataURI", Value.fromBytes(value));
  }

  get tagIds(): Array<BigInt> {
    let value = this.get("tagIds");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigIntArray();
    }
  }

  set tagIds(value: Array<BigInt>) {
    this.set("tagIds", Value.fromBigIntArray(value));
  }
}

export class Command extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Command entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type Command must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`,
      );
      store.set("Command", id.toString(), this);
    }
  }

  static loadInBlock(id: string): Command | null {
    return changetype<Command | null>(store.get_in_block("Command", id));
  }

  static load(id: string): Command | null {
    return changetype<Command | null>(store.get("Command", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get proposal(): string {
    let value = this.get("proposal");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set proposal(value: string) {
    this.set("proposal", Value.fromString(value));
  }

  get actions(): ActionLoader {
    return new ActionLoader("Command", this.get("id")!.toString(), "actions");
  }

  get currentScore(): BigInt {
    let value = this.get("currentScore");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set currentScore(value: BigInt) {
    this.set("currentScore", Value.fromBigInt(value));
  }
}

export class Action extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Action entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type Action must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`,
      );
      store.set("Action", id.toString(), this);
    }
  }

  static loadInBlock(id: string): Action | null {
    return changetype<Action | null>(store.get_in_block("Action", id));
  }

  static load(id: string): Action | null {
    return changetype<Action | null>(store.get("Action", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get command(): string {
    let value = this.get("command");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set command(value: string) {
    this.set("command", Value.fromString(value));
  }

  get func(): string {
    let value = this.get("func");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set func(value: string) {
    this.set("func", Value.fromString(value));
  }

  get abiParams(): Bytes {
    let value = this.get("abiParams");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBytes();
    }
  }

  set abiParams(value: Bytes) {
    this.set("abiParams", Value.fromBytes(value));
  }
}

export class ProposalMeta extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save ProposalMeta entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type ProposalMeta must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`,
      );
      store.set("ProposalMeta", id.toString(), this);
    }
  }

  static loadInBlock(id: string): ProposalMeta | null {
    return changetype<ProposalMeta | null>(
      store.get_in_block("ProposalMeta", id),
    );
  }

  static load(id: string): ProposalMeta | null {
    return changetype<ProposalMeta | null>(store.get("ProposalMeta", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get proposal(): string {
    let value = this.get("proposal");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set proposal(value: string) {
    this.set("proposal", Value.fromString(value));
  }

  get currentScore(): BigInt {
    let value = this.get("currentScore");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set currentScore(value: BigInt) {
    this.set("currentScore", Value.fromBigInt(value));
  }

  get headerRank(): Array<BigInt> {
    let value = this.get("headerRank");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigIntArray();
    }
  }

  set headerRank(value: Array<BigInt>) {
    this.set("headerRank", Value.fromBigIntArray(value));
  }

  get cmdRank(): Array<BigInt> {
    let value = this.get("cmdRank");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigIntArray();
    }
  }

  set cmdRank(value: Array<BigInt>) {
    this.set("cmdRank", Value.fromBigIntArray(value));
  }

  get nextHeaderTallyFrom(): BigInt {
    let value = this.get("nextHeaderTallyFrom");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set nextHeaderTallyFrom(value: BigInt) {
    this.set("nextHeaderTallyFrom", Value.fromBigInt(value));
  }

  get nextCmdTallyFrom(): BigInt {
    let value = this.get("nextCmdTallyFrom");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set nextCmdTallyFrom(value: BigInt) {
    this.set("nextCmdTallyFrom", Value.fromBigInt(value));
  }

  get reps(): Array<Bytes> {
    let value = this.get("reps");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBytesArray();
    }
  }

  set reps(value: Array<Bytes>) {
    this.set("reps", Value.fromBytesArray(value));
  }

  get nextRepId(): BigInt {
    let value = this.get("nextRepId");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set nextRepId(value: BigInt) {
    this.set("nextRepId", Value.fromBigInt(value));
  }

  get createdAt(): BigInt {
    let value = this.get("createdAt");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBigInt();
    }
  }

  set createdAt(value: BigInt) {
    this.set("createdAt", Value.fromBigInt(value));
  }
}

export class Text extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Text entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type Text must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`,
      );
      store.set("Text", id.toString(), this);
    }
  }

  static loadInBlock(id: string): Text | null {
    return changetype<Text | null>(store.get_in_block("Text", id));
  }

  static load(id: string): Text | null {
    return changetype<Text | null>(store.get("Text", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get metadataURIs(): Array<string> {
    let value = this.get("metadataURIs");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toStringArray();
    }
  }

  set metadataURIs(value: Array<string>) {
    this.set("metadataURIs", Value.fromStringArray(value));
  }

  get bodies(): Array<string> {
    let value = this.get("bodies");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toStringArray();
    }
  }

  set bodies(value: Array<string>) {
    this.set("bodies", Value.fromStringArray(value));
  }
}

export class Member extends Entity {
  constructor(id: string) {
    super();
    this.set("id", Value.fromString(id));
  }

  save(): void {
    let id = this.get("id");
    assert(id != null, "Cannot save Member entity without an ID");
    if (id) {
      assert(
        id.kind == ValueKind.STRING,
        `Entities of type Member must have an ID of type String but the id '${id.displayData()}' is of type ${id.displayKind()}`,
      );
      store.set("Member", id.toString(), this);
    }
  }

  static loadInBlock(id: string): Member | null {
    return changetype<Member | null>(store.get_in_block("Member", id));
  }

  static load(id: string): Member | null {
    return changetype<Member | null>(store.get("Member", id));
  }

  get id(): string {
    let value = this.get("id");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toString();
    }
  }

  set id(value: string) {
    this.set("id", Value.fromString(value));
  }

  get addr(): Bytes {
    let value = this.get("addr");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBytes();
    }
  }

  set addr(value: Bytes) {
    this.set("addr", Value.fromBytes(value));
  }

  get metadataURI(): Bytes {
    let value = this.get("metadataURI");
    if (!value || value.kind == ValueKind.NULL) {
      throw new Error("Cannot return null for a required field.");
    } else {
      return value.toBytes();
    }
  }

  set metadataURI(value: Bytes) {
    this.set("metadataURI", Value.fromBytes(value));
  }
}

export class HeaderLoader extends Entity {
  _entity: string;
  _field: string;
  _id: string;

  constructor(entity: string, id: string, field: string) {
    super();
    this._entity = entity;
    this._id = id;
    this._field = field;
  }

  load(): Header[] {
    let value = store.loadRelated(this._entity, this._id, this._field);
    return changetype<Header[]>(value);
  }
}

export class CommandLoader extends Entity {
  _entity: string;
  _field: string;
  _id: string;

  constructor(entity: string, id: string, field: string) {
    super();
    this._entity = entity;
    this._id = id;
    this._field = field;
  }

  load(): Command[] {
    let value = store.loadRelated(this._entity, this._id, this._field);
    return changetype<Command[]>(value);
  }
}

export class ProposalMetaLoader extends Entity {
  _entity: string;
  _field: string;
  _id: string;

  constructor(entity: string, id: string, field: string) {
    super();
    this._entity = entity;
    this._id = id;
    this._field = field;
  }

  load(): ProposalMeta[] {
    let value = store.loadRelated(this._entity, this._id, this._field);
    return changetype<ProposalMeta[]>(value);
  }
}

export class ActionLoader extends Entity {
  _entity: string;
  _field: string;
  _id: string;

  constructor(entity: string, id: string, field: string) {
    super();
    this._entity = entity;
    this._id = id;
    this._field = field;
  }

  load(): Action[] {
    let value = store.loadRelated(this._entity, this._id, this._field);
    return changetype<Action[]>(value);
  }
}
