import { BigInt } from "@graphprotocol/graph-ts";
import { assert, beforeEach, clearStore, describe, test } from "matchstick-as/assembly/index";
import { DeliberationConfig } from "../../generated/schema";
import {
  handleDeliberationConfigUpdated,
  handleDeliberationConfigUpdatedByProposal,
} from "../../src/event-handlers/deliberation-config-updated";
import { genDeliberationConfigId } from "../../src/utils/entity-id-provider";
import {
  createMockDeliberationConfigUpdatedByProposalEvent,
  createMockDeliberationConfigUpdatedEvent,
} from "../utils/mock-events";

describe("DeliberationConfig Event Handlers", () => {
  beforeEach(() => {
    clearStore();
  });

  test("Should create new DeliberationConfig entity if it doesn't exist", () => {
    const expiryDuration = BigInt.fromI32(86400); // 1 day
    const snapInterval = BigInt.fromI32(3600); // 1 hour
    const repsNum = BigInt.fromI32(5);
    const quorumScore = BigInt.fromI32(100);

    const event = createMockDeliberationConfigUpdatedEvent(expiryDuration, snapInterval, repsNum, quorumScore);

    handleDeliberationConfigUpdated(event);

    assert.entityCount("DeliberationConfig", 1);
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "expiryDuration", expiryDuration.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "snapInterval", snapInterval.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "repsNum", repsNum.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "quorumScore", quorumScore.toString());
    assert.fieldEquals(
      "DeliberationConfig",
      genDeliberationConfigId(),
      "lastUpdated",
      event.block.timestamp.toString(),
    );
  });

  test("Should update existing DeliberationConfig entity", () => {
    // Update config
    const newExpiryDuration = BigInt.fromI32(172800); // 2 days
    const newSnapInterval = BigInt.fromI32(7200); // 2 hours
    const newRepsNum = BigInt.fromI32(7);
    const newQuorumScore = BigInt.fromI32(150);
    const event = createMockDeliberationConfigUpdatedEvent(
      newExpiryDuration,
      newSnapInterval,
      newRepsNum,
      newQuorumScore,
    );

    // Create initial config
    const initialConfig = new DeliberationConfig(genDeliberationConfigId());
    initialConfig.expiryDuration = BigInt.fromI32(86400);
    initialConfig.snapInterval = BigInt.fromI32(3600);
    initialConfig.repsNum = BigInt.fromI32(5);
    initialConfig.quorumScore = BigInt.fromI32(100);
    initialConfig.lastUpdated = event.block.timestamp;
    initialConfig.save();

    handleDeliberationConfigUpdated(event);

    assert.entityCount("DeliberationConfig", 1);
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "expiryDuration", newExpiryDuration.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "snapInterval", newSnapInterval.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "repsNum", newRepsNum.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "quorumScore", newQuorumScore.toString());
    assert.fieldEquals(
      "DeliberationConfig",
      genDeliberationConfigId(),
      "lastUpdated",
      event.block.timestamp.toString(),
    );
  });

  test("Should handle multiple updates", () => {
    const expiryDurations = [BigInt.fromI32(86400), BigInt.fromI32(172800), BigInt.fromI32(259200)];
    const snapIntervals = [BigInt.fromI32(3600), BigInt.fromI32(7200), BigInt.fromI32(10800)];
    const repsNums = [BigInt.fromI32(5), BigInt.fromI32(7), BigInt.fromI32(9)];
    const quorumScores = [BigInt.fromI32(100), BigInt.fromI32(150), BigInt.fromI32(200)];

    for (let i = 0; i < 3; i++) {
      const event = createMockDeliberationConfigUpdatedEvent(
        expiryDurations[i],
        snapIntervals[i],
        repsNums[i],
        quorumScores[i],
      );

      handleDeliberationConfigUpdated(event);

      assert.entityCount("DeliberationConfig", 1);
      assert.fieldEquals(
        "DeliberationConfig",
        genDeliberationConfigId(),
        "expiryDuration",
        expiryDurations[i].toString(),
      );
      assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "snapInterval", snapIntervals[i].toString());
      assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "repsNum", repsNums[i].toString());
      assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "quorumScore", quorumScores[i].toString());
      assert.fieldEquals(
        "DeliberationConfig",
        genDeliberationConfigId(),
        "lastUpdated",
        event.block.timestamp.toString(),
      );
    }
  });

  test("Should handle DeliberationConfigUpdatedByProposal event", () => {
    const expiryDuration = BigInt.fromI32(86400); // 1 day
    const snapInterval = BigInt.fromI32(3600); // 1 hour
    const repsNum = BigInt.fromI32(5);
    const quorumScore = BigInt.fromI32(100);

    const event = createMockDeliberationConfigUpdatedByProposalEvent(
      expiryDuration,
      snapInterval,
      repsNum,
      quorumScore,
    );

    handleDeliberationConfigUpdatedByProposal(event);

    assert.entityCount("DeliberationConfig", 1);
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "expiryDuration", expiryDuration.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "snapInterval", snapInterval.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "repsNum", repsNum.toString());
    assert.fieldEquals("DeliberationConfig", genDeliberationConfigId(), "quorumScore", quorumScore.toString());
    assert.fieldEquals(
      "DeliberationConfig",
      genDeliberationConfigId(),
      "lastUpdated",
      event.block.timestamp.toString(),
    );
  });
});
