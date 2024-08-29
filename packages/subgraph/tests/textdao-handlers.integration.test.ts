import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts";
import {
  assert,
  beforeAll,
  beforeEach,
  clearStore,
  dataSourceMock,
  describe,
  log,
  mockIpfsFile,
  readFile,
  test,
} from "matchstick-as/assembly/index";
import { HeaderContents, Vote as VoteEntity } from "../generated/schema";
import { handleCommandCreated } from "../src/event-handlers/command-created";
import { handleHeaderCreated } from "../src/event-handlers/header-created";
import { handleProposalExecuted } from "../src/event-handlers/proposal-executed";
import { handleProposalSnapped } from "../src/event-handlers/proposal-snapped";
import { handleProposalTallied, handleProposalTalliedWithTie } from "../src/event-handlers/proposal-tallied";
import { handleProposed } from "../src/event-handlers/proposed";
import { handleRepresentativesAssigned } from "../src/event-handlers/representatives-assigned";
import { handleVoted } from "../src/event-handlers/voted";
import { handleHeaderContents } from "../src/file-data-handlers/header-contents";
import { genCommandId, genHeaderId, genProposalId, genVoteId } from "../src/utils/entity-id-provider";
import { loadProposal } from "../src/utils/entity-provider";
import { Action, Vote } from "../src/utils/schema-types";
import { formatAddressArray, formatBigIntArray, formatBigIntIdArray } from "../src/utils/type-formatter";
import {
  createMockCommandCreatedEvent,
  createMockHeaderCreatedEvent,
  createMockProposalExecutedEvent,
  createMockProposalSnappedEvent,
  createMockProposalTalliedEvent,
  createMockProposalTalliedWithTieEvent,
  createMockProposedEvent,
  createMockRepresentativesAssignedEvent,
  createMockVotedEvent,
} from "./utils/mock-events";

/**
 * Integration tests for TextDAO Subgraph event handlers
 *
 * These tests simulate real-world scenarios and event sequences in TextDAO,
 * ensuring that the subgraph correctly processes and stores data from multiple related events.
 */
describe("TextDAO Subgraph Integration Tests", () => {
  const headerMetadataCid = "QmHeader";
  const headerMetadataFilePath = "tests/utils/ipfs-file-data/sample-proposal-header-metadata1.json";

  beforeAll(() => {
    mockIpfsFile(headerMetadataCid, headerMetadataFilePath);
  });

  beforeEach(() => {
    clearStore();
  });

  test("Full proposal lifecycle", () => {
    const pid = BigInt.fromI32(0);
    const headerId1 = BigInt.fromI32(1);
    const createdAt = BigInt.fromI32(100000);
    const expirationTime = BigInt.fromI32(1100000);
    const snapInterval = BigInt.fromI32(72000);
    const reps = [
      Address.fromString("0x1234000000000000000000000000000000000000"),
      Address.fromString("0x2345000000000000000000000000000000000000"),
      Address.fromString("0x3456000000000000000000000000000000000000"),
    ];
    const proposer = Address.fromString("0xaaaa000000000000000000000000000000000000");

    // Create proposal
    dataSourceMock.setAddress(headerMetadataCid);
    handleHeaderCreated(createMockHeaderCreatedEvent(pid, headerId1, headerMetadataCid));
    handleHeaderContents(readFile(headerMetadataFilePath));
    handleRepresentativesAssigned(createMockRepresentativesAssignedEvent(pid, reps));
    handleProposed(createMockProposedEvent(pid, proposer, createdAt, expirationTime, snapInterval));

    const proposalEntityId = genProposalId(pid);
    const headerEntityId = genHeaderId(pid, headerId1);

    assert.entityCount("Proposal", 1);
    let proposal = loadProposal(pid);
    assert.assertNotNull(proposal);
    assert.stringEquals(proposal.id, proposalEntityId);

    let headers = proposal.headers.load();
    assert.i32Equals(headers.length, 1);
    let foundMatchingHeader = false;
    for (let i = 0; i < headers.length; i++) {
      const headerCid = headers[i].contents;
      let headerContents: HeaderContents | null = null;
      if (headerCid != null) {
        headerContents = HeaderContents.load(headerCid as string);
      }
      // log.info(headers[i].contents, []);
      // if (headerContents != null && headerContents.title != null) {
      // 	log.info(headerContents.title!, []);
      // }
      if (
        headers[i].id == headerEntityId &&
        headers[i].proposal == proposalEntityId &&
        headerContents != null &&
        headerContents.title == "Sample Header Title1"
      ) {
        // log.info("---", []);
        foundMatchingHeader = true;
        break;
      }
    }
    assert.assertTrue(foundMatchingHeader);

    assert.i32Equals(proposal.cmds.load().length, 0);
    assert.fieldEquals("Proposal", proposalEntityId, "proposer", proposer.toHexString());
    assert.fieldEquals("Proposal", proposalEntityId, "createdAt", createdAt.toString());
    assert.fieldEquals("Proposal", proposalEntityId, "expirationTime", expirationTime.toString());
    assert.fieldEquals("Proposal", proposalEntityId, "reps", formatAddressArray(reps));
    assert.i32Equals(proposal.votes.load().length, 0);
    // assert.assertNull(proposal.approvedHeaderId);
    // assert.assertNull(proposal.approvedCommandId);
    // assert.assertNull(proposal.fullyExecuted);
    // assert.assertNull(proposal.vrfRequestId);
    // assert.assertNull(proposal.snapped);
    // assert.assertNull(proposal.top3Headers);
    // assert.assertNull(proposal.top3Commands);
    log.info("Proposal is ok", []);
    log.info("pid: {}, headerId1: {}", [pid.toString(), headerId1.toString()]);
    log.info("Generated headerEntityId: {}", [headerEntityId]);

    // Fork proposal
    const headerId2 = BigInt.fromI32(2);
    const commandId1 = BigInt.fromI32(1);
    const actions = [new Action("memberJoin(uint256,(address,string)[])", Bytes.fromHexString("0xabcd"))];
    handleHeaderCreated(createMockHeaderCreatedEvent(pid, headerId2, headerMetadataCid));
    handleHeaderContents(readFile(headerMetadataFilePath));
    handleCommandCreated(createMockCommandCreatedEvent(pid, commandId1, actions));
    // log.info("---", []);
    proposal = loadProposal(pid);
    headers = proposal.headers.load();
    assert.i32Equals(headers.length, 2);
    let foundForkHeader = false;
    for (let i = 0; i < headers.length; i++) {
      const headerCid = headers[i].contents;
      let headerContents: HeaderContents | null = null;
      if (headerCid != null) {
        headerContents = HeaderContents.load(headerCid as string);
      }
      if (
        headers[i].id == genHeaderId(pid, headerId2) &&
        headers[i].proposal == proposalEntityId &&
        headerContents != null &&
        headerContents.title == "Sample Header Title1"
      ) {
        foundForkHeader = true;
        break;
      }
    }
    assert.assertTrue(foundForkHeader);
    // log.info("---", []);

    const cmds = proposal.cmds.load();
    assert.i32Equals(cmds.length, 1);
    let foundMatchingCommand = false;
    for (let i = 0; i < cmds.length; i++) {
      if (cmds[i].id == genCommandId(pid, commandId1) && cmds[i].proposal == proposalEntityId) {
        foundMatchingCommand = true;
        break;
      }
    }
    assert.assertTrue(foundMatchingCommand);
    // log.info("---", []);

    const command1 = cmds[0];
    const actions1 = command1.actions.load();
    assert.i32Equals(actions1.length, 1);

    let foundMatchingAction = false;
    for (let i = 0; i < actions1.length; i++) {
      if (
        actions1[i].command == command1.id &&
        actions1[i].func == actions[0].funcSig &&
        actions1[i].abiParams == actions[0].abiParams &&
        actions1[i].status == "Proposed"
      ) {
        foundMatchingAction = true;
        break;
      }
    }
    assert.assertTrue(foundMatchingAction);
    log.info("Fork is ok", []);

    // Voting
    const voter = [
      Address.fromString("0x1111000000000000000000000000000000000000"),
      Address.fromString("0x2222000000000000000000000000000000000000"),
      Address.fromString("0x3333000000000000000000000000000000000000"),
    ];
    const voteList = [
      new Vote(
        [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(0)],
        [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
      ),
      new Vote(
        [BigInt.fromI32(2), BigInt.fromI32(1), BigInt.fromI32(0)],
        [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
      ),
      new Vote(
        [BigInt.fromI32(2), BigInt.fromI32(1), BigInt.fromI32(0)],
        [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
      ),
    ];

    for (let i = 0; i < voteList.length; i++) {
      handleVoted(createMockVotedEvent(pid, voter[i], voteList[i]));

      proposal = loadProposal(pid);
      const votes = proposal.votes.load();
      let foundVote = false;
      for (let j = 0; j < votes.length; j++) {
        if (votes[j].rep == voter[i]) {
          assert.stringEquals(votes[j].proposal, proposalEntityId);
          assert.fieldEquals("Vote", votes[j].id, "rankedHeaderIds", formatBigIntArray(voteList[i].rankedHeaderIds));
          assert.fieldEquals("Vote", votes[j].id, "rankedCommandIds", formatBigIntArray(voteList[i].rankedCommandIds));
          foundVote = true;
          log.info("Vote is ok: ID is {}, Voter is {}", [votes[j].id, voter[i].toHexString()]);
          break;
        }
      }
      assert.assertTrue(foundVote);
    }

    assert.entityCount("Vote", 3);

    // Tally votes
    const approvedHeaderId = BigInt.fromI32(2);
    const approvedCommandId = BigInt.fromI32(1);
    handleProposalTallied(createMockProposalTalliedEvent(pid, approvedHeaderId, approvedCommandId));

    assert.i32Equals(headers.length, 2);
    assert.i32Equals(cmds.length, 1);
    assert.fieldEquals("Proposal", proposalEntityId, "approvedHeaderId", approvedHeaderId.toString());
    assert.fieldEquals("Proposal", proposalEntityId, "approvedCommandId", approvedCommandId.toString());

    // Execute proposal
    handleProposalExecuted(createMockProposalExecutedEvent(pid, approvedCommandId));

    assert.fieldEquals("Proposal", proposalEntityId, "fullyExecuted", "true");
  });

  test("Proposal with voting tie and resolution", () => {
    const pid = BigInt.fromI32(1);
    const proposer = Address.fromString("0xaaaa000000000000000000000000000000000000");
    const expirationTime = BigInt.fromI32(2100000);
    const extendedExpirationTime = BigInt.fromI32(2200000);
    const snapInterval = BigInt.fromI32(72000);
    const reps = [
      Address.fromString("0x1234000000000000000000000000000000000000"),
      Address.fromString("0x2345000000000000000000000000000000000000"),
      Address.fromString("0x3456000000000000000000000000000000000000"),
    ];

    // Create proposal
    handleHeaderCreated(createMockHeaderCreatedEvent(pid, BigInt.fromI32(1), headerMetadataCid));
    handleRepresentativesAssigned(createMockRepresentativesAssignedEvent(pid, reps));
    handleProposed(createMockProposedEvent(pid, proposer, BigInt.fromI32(2000000), expirationTime, snapInterval));

    // Fork proposal
    const actions = [new Action("memberJoin(uint256,(address,string)[])", Bytes.fromHexString("0x1234"))];
    handleHeaderCreated(createMockHeaderCreatedEvent(pid, BigInt.fromI32(2), headerMetadataCid));
    handleCommandCreated(createMockCommandCreatedEvent(pid, BigInt.fromI32(1), actions));

    // Two members vote differently, causing a tie
    const vote1 = new Vote(
      [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(0)],
      [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
    );
    handleVoted(createMockVotedEvent(pid, reps[0], vote1));

    const vote2 = new Vote(
      [BigInt.fromI32(2), BigInt.fromI32(1), BigInt.fromI32(0)],
      [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
    );
    handleVoted(createMockVotedEvent(pid, reps[1], vote2));

    // Tally votes, expect a tie
    const tieHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2)];
    const tieCommandIds = [BigInt.fromI32(1)];
    handleProposalTalliedWithTie(
      createMockProposalTalliedWithTieEvent(pid, tieHeaderIds, tieCommandIds, extendedExpirationTime),
    );

    const proposalEntityId = genProposalId(pid);
    assert.fieldEquals("Proposal", proposalEntityId, "expirationTime", extendedExpirationTime.toString());
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "top3Headers",
      formatBigIntIdArray(pid, tieHeaderIds, genHeaderId),
    );
    assert.fieldEquals(
      "Proposal",
      proposalEntityId,
      "top3Commands",
      formatBigIntIdArray(pid, tieCommandIds, genCommandId),
    );

    // Third member votes during extended period
    const vote3 = new Vote(
      [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(0)],
      [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
    );
    handleVoted(createMockVotedEvent(pid, reps[2], vote3));

    // Tally votes again, expect resolution
    handleProposalTallied(createMockProposalTalliedEvent(pid, BigInt.fromI32(1), BigInt.fromI32(1)));

    assert.fieldEquals("Proposal", proposalEntityId, "approvedHeaderId", "1");
    assert.fieldEquals("Proposal", proposalEntityId, "approvedCommandId", "1");
  });

  test(
    "Error handling and edge cases",
    () => {
      const MEMBER1 = Address.fromString("0x1234000000000000000000000000000000000000");
      const MEMBER2 = Address.fromString("0x2345000000000000000000000000000000000000");
      const MEMBER3 = Address.fromString("0x3456000000000000000000000000000000000000");

      const pid = BigInt.fromI32(2);
      const headerId = BigInt.fromI32(1);
      const proposer = Address.fromString("0x9999990000000000000000000000000000000000");
      const createdAt = BigInt.fromI32(17200000);
      const expirationTime = BigInt.fromI32(3100000);
      const snapInterval = BigInt.fromI32(72000);
      const reps = [MEMBER1, MEMBER2, MEMBER3];

      // Create proposal
      handleHeaderCreated(createMockHeaderCreatedEvent(pid, headerId, headerMetadataCid));
      handleRepresentativesAssigned(createMockRepresentativesAssignedEvent(pid, reps));
      handleProposed(createMockProposedEvent(pid, proposer, createdAt, expirationTime, snapInterval));

      // Test premature tally attempt (ProposalSnapped event)
      const epoch = BigInt.fromI32(17000000);
      handleProposalSnapped(createMockProposalSnappedEvent(pid, epoch, new Array<BigInt>(), new Array<BigInt>()));

      const proposal = loadProposal(pid);
      assert.assertNotNull(proposal.snappedEpoch);
      assert.fieldEquals("Proposal", proposal.id, "snappedEpoch", `[${epoch.toString()}]`);
      log.info("Proposal snapped successfully at epoch: {}", [epoch.toString()]);

      // Non-existent proposal
      const nonExistentProposalId = BigInt.fromI32(999);
      const nonExistentProposalEntityId = genProposalId(nonExistentProposalId);

      // Attempt to vote on a non-existent proposal
      const vote = new Vote(
        [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
        [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
      );
      handleVoted(createMockVotedEvent(nonExistentProposalId, MEMBER1, vote));

      // Verify that no Vote entity was created
      const voteId = genVoteId(nonExistentProposalId, MEMBER1);
      assert.assertNotNull(VoteEntity.load(voteId));

      // Attempt to tally a non-existent proposal
      handleProposalTallied(
        createMockProposalTalliedEvent(nonExistentProposalId, BigInt.fromI32(1), BigInt.fromI32(1)),
      );
    },
    true,
  );
});
