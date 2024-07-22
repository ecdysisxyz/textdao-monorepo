import {
  assert,
  describe,
  test,
  clearStore,
  beforeEach,
} from "matchstick-as/assembly/index";
import { Bytes } from "@graphprotocol/graph-ts";
import { handleHeaderScored, handleHeaderProposed } from "../src/mapping";
import { createHeaderScored, createHeaderProposed } from "./utils";

describe("HeaderScored", () => {
  beforeEach(() => {
    clearStore();
    const uriHex = Bytes.fromUTF8("uri").toHex();
    handleHeaderProposed(createHeaderProposed(1, 2, 3, uriHex, 4, 5));
  });

  test("update currentScore", () => {
    assert.fieldEquals("Header", "1", "currentScore", "3");
    handleHeaderScored(createHeaderScored(1, 2, 5));
    assert.fieldEquals("Header", "1", "currentScore", "5");
  });
});
