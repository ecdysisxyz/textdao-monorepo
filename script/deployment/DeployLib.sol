// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "@devkit/Flattened.sol";

import {Clone} from "@mc-std/functions/Clone.sol";

import {Initialize} from "bundle/textDAO/functions/initializer/Initialize.sol";
import {Propose} from "bundle/textDAO/functions/onlyMember/Propose.sol";
import {Vote} from "bundle/textDAO/functions/onlyMember/Vote.sol";
import {Fork} from "bundle/textDAO/functions/onlyReps/Fork.sol";
import {RawFulfillRandomWords} from "bundle/textDAO/functions/onlyVrfCoordinator/RawFulfillRandomWords.sol";
import {ConfigOverrideProtected} from "bundle/textDAO/functions/protected/ConfigOverrideProtected.sol";
import {MemberJoinProtected} from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";
import {SaveTextProtected} from "bundle/textDAO/functions/protected/SaveTextProtected.sol";
import {SetConfigsProtected} from "bundle/textDAO/functions/protected/SetConfigsProtected.sol";
import {Execute} from "bundle/textDAO/functions/Execute.sol";
import {Getter} from "bundle/textDAO/functions/Getter.sol";
import {Tally} from "bundle/textDAO/functions/Tally.sol";

import {TextDAOFacade} from "bundle/textDAO/interfaces/TextDAOFacade.sol";

library DeployLib {
    string internal constant BUNDLE_NAME = "TextDAO";

    function deployTextDAO(MCDevKit storage mc) internal returns(address textDAO) {
        mc.init(BUNDLE_NAME);
        mc.use("Clone", Clone.clone.selector, address(new Clone()));
        mc.use("Initialize", Initialize.initialize.selector, address(new Initialize()));
        mc.use("Propose", Propose.propose.selector, address(new Propose()));
        mc.use("Fork", Fork.fork.selector, address(new Fork()));
        address voteAddr = address(new Vote());
        mc.use("VoteHeaders", Vote.voteHeaders.selector, voteAddr);
        mc.use("VoteCmds", Vote.voteCmds.selector, voteAddr);
        mc.use("Tally", Tally.tally.selector, address(new Tally()));
        mc.use("Execute", Execute.execute.selector, address(new Execute()));
        mc.use("MemberJoinProtected", MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
        mc.use("SetConfigsProtected", SetConfigsProtected.setProposalsConfig.selector, address(new SetConfigsProtected()));
        mc.use("ConfigOverrideProtected", ConfigOverrideProtected.overrideProposalsConfig.selector, address(new ConfigOverrideProtected()));
        mc.use("SaveTextProtected", SaveTextProtected.saveText.selector, address(new SaveTextProtected()));
        address getter = address(new Getter());
        mc.use("getProposal", Getter.getProposal.selector, getter);
        mc.use("getProposalHeaders", Getter.getProposalHeaders.selector, getter);
        mc.use("getProposalCommand", Getter.getProposalCommand.selector, getter);
        mc.use("getProposalsConfig", Getter.getProposalsConfig.selector, getter);
        mc.use("getText", Getter.getText.selector, getter);
        mc.use("getTexts", Getter.getTexts.selector, getter);
        mc.use("getMember", Getter.getMember.selector, getter);
        mc.use("getMembers", Getter.getMembers.selector, getter);
        // mc.use("getVRFRequest", Getter.getVRFRequest.selector, getter);
        // mc.use("getNextVRFId", Getter.getNextVRFId.selector, getter);
        mc.use("getSubscriptionId", Getter.getSubscriptionId.selector, getter);
        mc.use("getVRFConfig", Getter.getVRFConfig.selector, getter);
        mc.use("getConfigOverride", Getter.getConfigOverride.selector, getter);

        mc.useFacade(address(new TextDAOFacade())); // for Etherscan proxy read/write

        return mc.deploy().toProxyAddress();
    }
}
