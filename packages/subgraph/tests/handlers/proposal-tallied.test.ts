import { BigInt } from "@graphprotocol/graph-ts";
import { assert, beforeEach, clearStore, describe, test } from "matchstick-as/assembly/index";
import { handleProposalTallied, handleProposalTalliedWithTie } from "../../src/event-handlers/proposal-tallied";
import {
  genCommandId,
  genHeaderId,
  genProposalId,
  genTopCommandId,
  genTopHeaderId,
} from "../../src/utils/entity-id-provider";
import { createMockProposalEntity } from "../utils/mock-entities";
import { createMockProposalTalliedEvent, createMockProposalTalliedWithTieEvent } from "../utils/mock-events";

describe("ProposalTallied Event Handler", () => {
  beforeEach(() => {
    clearStore();
  });

  test("Should update Proposal entity with approvedHeaderId and approvedCommandId", () => {
    const pid = BigInt.fromI32(100);
    const approvedHeaderId = BigInt.fromI32(1);
    const approvedCommandId = BigInt.fromI32(2);

    createMockProposalEntity(pid);

    handleProposalTallied(createMockProposalTalliedEvent(pid, approvedHeaderId, approvedCommandId));

    const proposalEntityId = genProposalId(pid);

    assert.fieldEquals("Proposal", proposalEntityId, "id", proposalEntityId);
    assert.fieldEquals("Proposal", proposalEntityId, "approvedHeaderId", approvedHeaderId.toString());
    assert.fieldEquals("Proposal", proposalEntityId, "approvedCommandId", approvedCommandId.toString());
  });

  test(
    "Should fail if Proposal entity does not exist",
    () => {
      const pid = BigInt.fromI32(100);
      const approvedHeaderId = BigInt.fromI32(1);
      const approvedCommandId = BigInt.fromI32(2);

      handleProposalTallied(createMockProposalTalliedEvent(pid, approvedHeaderId, approvedCommandId));

      assert.entityCount("Proposal", 0);
    },
    true,
  );
});

describe("ProposalTalliedWithTie Event Handler", () => {
  beforeEach(() => {
    clearStore();
  });

  test("Should update Proposal entity with expirationTime and create TopHeader and TopCommand entities", () => {
    const pid = BigInt.fromI32(100);
    const epoch = BigInt.fromI32(1000);
    const extendedExpirationTime = BigInt.fromI32(123456);
    const topHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];
    const topCommandIds = [BigInt.fromI32(4), BigInt.fromI32(5), BigInt.fromI32(6)];

    createMockProposalEntity(pid);

    handleProposalTalliedWithTie(
      createMockProposalTalliedWithTieEvent(pid, epoch, topHeaderIds, topCommandIds, extendedExpirationTime),
    );

    const proposalEntityId = genProposalId(pid);

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "expirationTime",
      extendedExpirationTime.toString(),
      "proposal.expirationTime should be match with extendedExpirationTime.",
    );

    // Check TopHeader entities
    assert.entityCount("TopHeader", topHeaderIds.length, "TopHeader should be added.");
    for (let i = 0; i < topHeaderIds.length; i++) {
      const topHeaderId = genTopHeaderId(pid, epoch, i);
      assert.fieldEquals(
        "TopHeader",
        topHeaderId,
        "snappedEpoch",
        epoch.toString(),
        "TopHeader.snappedEpoch should be saved.",
      );
      assert.fieldEquals(
        "TopHeader",
        topHeaderId,
        "index",
        BigInt.fromI32(i).toString(),
        "TopHeader.index should be saved.",
      );
      assert.fieldEquals(
        "TopHeader",
        topHeaderId,
        "header",
        genHeaderId(pid, topHeaderIds[i]),
        "TopHeader.headerId should be saved.",
      );
    }

    // Check TopCommand entities
    assert.entityCount("TopCommand", topCommandIds.length, "TopCommand should be added.");
    for (let i = 0; i < topCommandIds.length; i++) {
      const topCommandId = genTopCommandId(pid, epoch, i);
      assert.fieldEquals(
        "TopCommand",
        topCommandId,
        "snappedEpoch",
        epoch.toString(),
        "TopCommand.snappedEpoch should be saved.",
      );
      assert.fieldEquals(
        "TopCommand",
        topCommandId,
        "index",
        BigInt.fromI32(i).toString(),
        "TopCommand.index should be saved.",
      );
      assert.fieldEquals(
        "TopCommand",
        topCommandId,
        "command",
        genCommandId(pid, topCommandIds[i]),
        "TopCommand.headerId should be saved.",
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

    assert.fieldEquals("Proposal", proposalEntityId, "topHeaders", `[${expectedTopHeaders}]`);
    assert.fieldEquals("Proposal", proposalEntityId, "topCommands", `[${expectedTopCommands}]`);
  });

  test(
    "Should fail if Proposal entity does not exist",
    () => {
      const pid = BigInt.fromI32(100);
      const epoch = BigInt.fromI32(1000);
      const extendedExpirationTime = BigInt.fromI32(123456);
      const topHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];
      const topCommandIds = [BigInt.fromI32(4), BigInt.fromI32(5), BigInt.fromI32(6)];

      handleProposalTalliedWithTie(
        createMockProposalTalliedWithTieEvent(pid, epoch, topHeaderIds, topCommandIds, extendedExpirationTime),
      );
    },
    true,
  );
});
