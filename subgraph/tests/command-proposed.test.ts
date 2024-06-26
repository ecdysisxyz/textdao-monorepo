import {
  assert,
  describe,
  test,
  clearStore,
  beforeEach,
} from "matchstick-as/assembly/index";
import { Bytes } from "@graphprotocol/graph-ts";
import { handleCommandProposed } from "../src/mapping";
import { createCommandProposed } from "./utils";

describe("CommandProposed", () => {
  beforeEach(() => {
    clearStore();
  });

  test("create and store Command and Action", () => {
    assert.entityCount("Command", 0);
    let abiParams1Hex = Bytes.fromUTF8("abi1").toHex();
    let abiParams2Hex = Bytes.fromUTF8("abi2").toHex();
    handleCommandProposed(
      createCommandProposed(
        1,
        2,
        "func1",
        "func2",
        abiParams1Hex,
        abiParams2Hex,
        3,
        "0x01"
      )
    );
    assert.entityCount("Command", 1);
    assert.entityCount("Action", 2);

    assert.fieldEquals("Command", "1", "id", "1");
    assert.fieldEquals("Command", "1", "proposal", "2");
    assert.fieldEquals("Command", "1", "currentScore", "3");
    assert.fieldEquals("Action", "0x01-0", "func", "func1");
    assert.fieldEquals("Action", "0x01-0", "abiParams", abiParams1Hex);
    assert.fieldEquals("Action", "0x01-1", "func", "func2");
    assert.fieldEquals("Action", "0x01-1", "abiParams", abiParams2Hex);
  });

  test("create or update Command", () => {
    assert.entityCount("Command", 0);
    let abiParams1Hex = Bytes.fromUTF8("abi1").toHex();
    let abiParams2Hex = Bytes.fromUTF8("abi2").toHex();
    handleCommandProposed(
      createCommandProposed(
        1,
        2,
        "func1",
        "func2",
        abiParams1Hex,
        abiParams2Hex,
        3,
        "0x01"
      )
    );
    handleCommandProposed(
      createCommandProposed(
        1,
        12,
        "func11",
        "func12",
        abiParams1Hex,
        abiParams2Hex,
        13,
        "0x02"
      )
    );
    assert.entityCount("Command", 1);
    assert.entityCount("Action", 2);

    assert.fieldEquals("Command", "1", "id", "1");
    assert.fieldEquals("Command", "1", "proposal", "12");
    assert.fieldEquals("Command", "1", "currentScore", "13");
    assert.fieldEquals("Action", "0x02-0", "func", "func11");
    assert.fieldEquals("Action", "0x02-0", "abiParams", abiParams1Hex);
    assert.fieldEquals("Action", "0x02-1", "func", "func12");
    assert.fieldEquals("Action", "0x02-1", "abiParams", abiParams2Hex);
  });

  test("create 2 Command", () => {
    assert.entityCount("Command", 0);
    let abiParams1Hex = Bytes.fromUTF8("abi1").toHex();
    let abiParams2Hex = Bytes.fromUTF8("abi2").toHex();
    handleCommandProposed(
      createCommandProposed(
        1,
        2,
        "func1",
        "func2",
        abiParams1Hex,
        abiParams2Hex,
        3,
        "0x01"
      )
    );
    handleCommandProposed(
      createCommandProposed(
        2,
        12,
        "func11",
        "func12",
        abiParams1Hex,
        abiParams2Hex,
        13,
        "0x02"
      )
    );
    assert.entityCount("Command", 2);
  });
});
