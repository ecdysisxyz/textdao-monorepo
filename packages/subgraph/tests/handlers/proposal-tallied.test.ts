import { BigInt } from "@graphprotocol/graph-ts";
import { assert, beforeEach, clearStore, describe, test } from "matchstick-as/assembly/index";
import { handleProposalTallied, handleProposalTalliedWithTie } from "../../src/event-handlers/proposal-tallied";
import { genCommandId, genHeaderId, genProposalId } from "../../src/utils/entity-id-provider";
import { formatBigIntIdArray } from "../../src/utils/type-formatter";
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

  test("Should update Proposal entity with expirationTime, top3Headers, and top3Commands", () => {
    const pid = BigInt.fromI32(100);
    const extendedExpirationTime = BigInt.fromI32(123456);
    const approvedHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];
    const approvedCommandIds = [BigInt.fromI32(4), BigInt.fromI32(5), BigInt.fromI32(6)];

    createMockProposalEntity(pid);

    handleProposalTalliedWithTie(
      createMockProposalTalliedWithTieEvent(pid, approvedHeaderIds, approvedCommandIds, extendedExpirationTime),
    );

    const proposalEntityId = genProposalId(pid);

    assert.fieldEquals("Proposal", proposalEntityId, "expirationTime", extendedExpirationTime.toString());

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "top3Headers",
      formatBigIntIdArray(pid, approvedHeaderIds, genHeaderId),
    );

    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "top3Commands",
      formatBigIntIdArray(pid, approvedCommandIds, genCommandId),
    );
  });

  test(
    "Should fail if Proposal entity does not exist",
    () => {
      const pid = BigInt.fromI32(100);
      const extendedExpirationTime = BigInt.fromI32(123456);
      const approvedHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)];
      const approvedCommandIds = [BigInt.fromI32(4), BigInt.fromI32(5), BigInt.fromI32(6)];

      handleProposalTalliedWithTie(
        createMockProposalTalliedWithTieEvent(pid, approvedHeaderIds, approvedCommandIds, extendedExpirationTime),
      );
    },
    true,
  );
});
