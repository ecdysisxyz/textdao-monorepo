import { BigInt } from "@graphprotocol/graph-ts";
import { assert, beforeEach, clearStore, describe, test } from "matchstick-as/assembly/index";
import { handleProposalSnapped } from "../../src/event-handlers/proposal-snapped";
import {
  genCommandId,
  genHeaderId,
  genProposalId,
  genTopCommandId,
  genTopHeaderId,
} from "../../src/utils/entity-id-provider";
import { createMockProposalEntity } from "../utils/mock-entities";
import { createMockProposalSnappedEvent } from "../utils/mock-events";

describe("ProposalSnapped Event Handler", () => {
  beforeEach(() => {
    clearStore();
  });

  test("Should update existing Proposal entity with topHeaders, topCommands, snappedEpoch, and snappedTimes in correct order", () => {
    const pid = BigInt.fromI32(100);
    const epoch = BigInt.fromI32(1721900000);
    const timestamp = BigInt.fromI32(1721900001);
    const topHeaderIds = [BigInt.fromI32(3), BigInt.fromI32(1), BigInt.fromI32(2)];
    const topCommandIds = [BigInt.fromI32(2), BigInt.fromI32(3), BigInt.fromI32(1)];

    // Create a proposal first
    createMockProposalEntity(pid);

    const event = createMockProposalSnappedEvent(pid, epoch, topHeaderIds, topCommandIds);
    event.block.timestamp = timestamp;
    handleProposalSnapped(event);

    const proposalEntityId = genProposalId(pid);

    assert.entityCount("Proposal", 1, "Proposal entity should exist");
    assert.fieldEquals("Proposal", proposalEntityId, "id", proposalEntityId, "Proposal ID should match");

    // Check TopHeader entities
    assert.entityCount("TopHeader", topHeaderIds.length, "TopHeader entities should be created");
    for (let i = 0; i < topHeaderIds.length; i++) {
      const topHeaderId = genTopHeaderId(pid, epoch, i);
      assert.fieldEquals(
        "TopHeader",
        topHeaderId,
        "snappedEpoch",
        epoch.toString(),
        "TopHeader snappedEpoch should match",
      );
      assert.fieldEquals(
        "TopHeader",
        topHeaderId,
        "index",
        BigInt.fromI32(i).toString(),
        "TopHeader index should match",
      );
      assert.fieldEquals(
        "TopHeader",
        topHeaderId,
        "header",
        genHeaderId(pid, topHeaderIds[i]),
        "TopHeader header reference should match",
      );
    }

    // Check TopCommand entities
    assert.entityCount("TopCommand", topCommandIds.length, "TopCommand entities should be created");
    for (let i = 0; i < topCommandIds.length; i++) {
      const topCommandId = genTopCommandId(pid, epoch, i);
      assert.fieldEquals(
        "TopCommand",
        topCommandId,
        "snappedEpoch",
        epoch.toString(),
        "TopCommand snappedEpoch should match",
      );
      assert.fieldEquals(
        "TopCommand",
        topCommandId,
        "index",
        BigInt.fromI32(i).toString(),
        "TopCommand index should match",
      );
      assert.fieldEquals(
        "TopCommand",
        topCommandId,
        "command",
        genCommandId(pid, topCommandIds[i]),
        "TopCommand command reference should match",
      );
    }

    // Check that Proposal entity has correct references to TopHeader and TopCommand entities
    let expectedTopHeaders = "";
    let expectedTopCommands = "";

    for (let i = 0; i < topHeaderIds.length; i++) {
      if (i > 0) expectedTopHeaders += ", ";
      expectedTopHeaders += genTopHeaderId(pid, epoch, i);
    }

    for (let i = 0; i < topCommandIds.length; i++) {
      if (i > 0) expectedTopCommands += ", ";
      expectedTopCommands += genTopCommandId(pid, epoch, i);
    }

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topHeaders",
      `[${expectedTopHeaders}]`,
      "Proposal topHeaders should match created TopHeader entities",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topCommands",
      `[${expectedTopCommands}]`,
      "Proposal topCommands should match created TopCommand entities",
    );

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "snappedEpoch",
      `[${epoch.toString()}]`,
      "Proposal snappedEpoch should be updated",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "snappedTimes",
      `[${timestamp.toString()}]`,
      "Proposal snappedTimes should be updated",
    );
  });

  test(
    "Should fail if Proposal entity doesn't exist",
    () => {
      const pid = BigInt.fromI32(100);
      const epoch = BigInt.fromI32(1721900000);
      const topHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];
      const topCommandIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];

      assert.entityCount("Proposal", 0);
      handleProposalSnapped(createMockProposalSnappedEvent(pid, epoch, topHeaderIds, topCommandIds));
      assert.entityCount("Proposal", 0);
    },
    true,
  );

  test("Should update existing Proposal entity with new values and append new epoch", () => {
    const pid = BigInt.fromI32(100);
    const epoch1 = BigInt.fromI32(1721900000);
    const epoch2 = BigInt.fromI32(1721900100);
    const initialTopHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];
    const initialTopCommandIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];
    const updatedTopHeaderIds = [BigInt.fromI32(4), BigInt.fromI32(5), BigInt.fromI32(6)];
    const updatedTopCommandIds = [BigInt.fromI32(4), BigInt.fromI32(5), BigInt.fromI32(6)];

    // Create a proposal first
    createMockProposalEntity(pid);

    handleProposalSnapped(createMockProposalSnappedEvent(pid, epoch1, initialTopHeaderIds, initialTopCommandIds));
    handleProposalSnapped(createMockProposalSnappedEvent(pid, epoch2, updatedTopHeaderIds, updatedTopCommandIds));

    const proposalEntityId = genProposalId(pid);

    assert.entityCount("Proposal", 1, "Proposal entity should still exist after multiple snaps");

    let expectedUpdatedTopHeaders = "";
    let expectedUpdatedTopCommands = "";

    for (let i = 0; i < updatedTopHeaderIds.length; i++) {
      if (i > 0) expectedUpdatedTopHeaders += ", ";
      expectedUpdatedTopHeaders += genTopHeaderId(pid, epoch2, i);
    }

    for (let i = 0; i < updatedTopCommandIds.length; i++) {
      if (i > 0) expectedUpdatedTopCommands += ", ";
      expectedUpdatedTopCommands += genTopCommandId(pid, epoch2, i);
    }

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topHeaders",
      `[${expectedUpdatedTopHeaders}]`,
      "Proposal topHeaders should be updated with the latest snap",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topCommands",
      `[${expectedUpdatedTopCommands}]`,
      "Proposal topCommands should be updated with the latest snap",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "snappedEpoch",
      `[${epoch1.toString()}, ${epoch2.toString()}]`,
      "Proposal snappedEpoch should contain both epochs",
    );
  });

  test("Should handle less than 3 top headers or commands", () => {
    const pid = BigInt.fromI32(100);
    const epoch = BigInt.fromI32(1721900000);
    const topHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2)];
    const topCommandIds = [BigInt.fromI32(1)];

    // Create a proposal first
    createMockProposalEntity(pid);

    handleProposalSnapped(createMockProposalSnappedEvent(pid, epoch, topHeaderIds, topCommandIds));

    const proposalEntityId = genProposalId(pid);

    let expectedTopHeaders = "";
    let expectedTopCommands = "";

    for (let i = 0; i < topHeaderIds.length; i++) {
      if (i > 0) expectedTopHeaders += ", ";
      expectedTopHeaders += genTopHeaderId(pid, epoch, i);
    }

    for (let i = 0; i < topCommandIds.length; i++) {
      if (i > 0) expectedTopCommands += ", ";
      expectedTopCommands += genTopCommandId(pid, epoch, i);
    }

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topHeaders",
      `[${expectedTopHeaders}]`,
      "Proposal topHeaders should match created TopHeader entities even with less than 3",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topCommands",
      `[${expectedTopCommands}]`,
      "Proposal topCommands should match created TopCommand entities even with less than 3",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "snappedEpoch",
      `[${epoch.toString()}]`,
      "Proposal snappedEpoch should be updated",
    );
  });

  test("Should handle empty top headers or commands", () => {
    const pid = BigInt.fromI32(100);
    const epoch = BigInt.fromI32(1721900000);
    const topHeaderIds: BigInt[] = [];
    const topCommandIds: BigInt[] = [];

    // Create a proposal first
    createMockProposalEntity(pid);

    handleProposalSnapped(createMockProposalSnappedEvent(pid, epoch, topHeaderIds, topCommandIds));

    const proposalEntityId = genProposalId(pid);

    assert.fieldEquals("Proposal", proposalEntityId, "topHeaders", "[]", "Proposal topHeaders should be empty");
    assert.fieldEquals("Proposal", proposalEntityId, "topCommands", "[]", "Proposal topCommands should be empty");
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "snappedEpoch",
      `[${epoch.toString()}]`,
      "Proposal snappedEpoch should be updated",
    );
  });

  test("Should handle large proposal ID and large header/command IDs", () => {
    const pid = BigInt.fromI32(999999);
    const epoch = BigInt.fromI32(1721900000);
    const topHeaderIds = [BigInt.fromI32(1000000), BigInt.fromI32(2000000), BigInt.fromI32(3000000)];
    const topCommandIds = [BigInt.fromI32(4000000), BigInt.fromI32(5000000), BigInt.fromI32(6000000)];

    // Create a proposal first
    createMockProposalEntity(pid);

    handleProposalSnapped(createMockProposalSnappedEvent(pid, epoch, topHeaderIds, topCommandIds));

    const proposalEntityId = genProposalId(pid);

    let expectedTopHeaders = "";
    let expectedTopCommands = "";

    for (let i = 0; i < topHeaderIds.length; i++) {
      if (i > 0) expectedTopHeaders += ", ";
      expectedTopHeaders += genTopHeaderId(pid, epoch, i);
    }

    for (let i = 0; i < topCommandIds.length; i++) {
      if (i > 0) expectedTopCommands += ", ";
      expectedTopCommands += genTopCommandId(pid, epoch, i);
    }

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topHeaders",
      `[${expectedTopHeaders}]`,
      "Proposal topHeaders should match created TopHeader entities even with large IDs",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topCommands",
      `[${expectedTopCommands}]`,
      "Proposal topCommands should match created TopCommand entities even with large IDs",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "snappedEpoch",
      `[${epoch.toString()}]`,
      "Proposal snappedEpoch should be updated",
    );
  });

  test("Should handle multiple snaps and append all epochs", () => {
    const pid = BigInt.fromI32(100);
    const epochs = [BigInt.fromI32(1721900000), BigInt.fromI32(1721900100), BigInt.fromI32(1721900200)];
    const timestamps = [BigInt.fromI32(1621900000), BigInt.fromI32(1621900100), BigInt.fromI32(1621900200)];
    const topHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2)];
    const topCommandIds = [BigInt.fromI32(1)];

    // Create a proposal first
    createMockProposalEntity(pid);

    for (let i = 0; i < epochs.length; i++) {
      const event = createMockProposalSnappedEvent(pid, epochs[i], topHeaderIds, topCommandIds);
      event.block.timestamp = timestamps[i];
      handleProposalSnapped(event);
    }

    const proposalEntityId = genProposalId(pid);

    let expectedSnappedEpochs = "";
    let expectedSnappedTimes = "";

    for (let i = 0; i < epochs.length; i++) {
      if (i > 0) {
        expectedSnappedEpochs += ", ";
        expectedSnappedTimes += ", ";
      }
      expectedSnappedEpochs += epochs[i].toString();
      expectedSnappedTimes += timestamps[i].toString();
    }

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "snappedEpoch",
      `[${expectedSnappedEpochs}]`,
      "Proposal snappedEpoch should contain all epochs",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "snappedTimes",
      `[${expectedSnappedTimes}]`,
      "Proposal snappedTimes should contain all timestamps",
    );

    // Check the latest topHeaders and topCommands
    let expectedTopHeaders = "";
    let expectedTopCommands = "";

    for (let i = 0; i < topHeaderIds.length; i++) {
      if (i > 0) expectedTopHeaders += ", ";
      expectedTopHeaders += genTopHeaderId(pid, epochs[epochs.length - 1], i);
    }

    for (let i = 0; i < topCommandIds.length; i++) {
      if (i > 0) expectedTopCommands += ", ";
      expectedTopCommands += genTopCommandId(pid, epochs[epochs.length - 1], i);
    }

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topHeaders",
      `[${expectedTopHeaders}]`,
      "Proposal topHeaders should match the latest snap",
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "topCommands",
      `[${expectedTopCommands}]`,
      "Proposal topCommands should match the latest snap",
    );
  });

  test(
    "Should fail if Proposal entity doesn't exist",
    () => {
      const pid = BigInt.fromI32(100);
      const epoch = BigInt.fromI32(1721900000);
      const topHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];
      const topCommandIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];

      assert.entityCount("Proposal", 0);
      handleProposalSnapped(createMockProposalSnappedEvent(pid, epoch, topHeaderIds, topCommandIds));
      assert.entityCount("Proposal", 0);
    },
    true,
  );
});
