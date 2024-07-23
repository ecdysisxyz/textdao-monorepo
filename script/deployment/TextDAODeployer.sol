// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "@devkit/Flattened.sol";

import {Clone} from "@mc-std/functions/Clone.sol";

import {Initialize} from "bundle/textDAO/functions/initializer/Initialize.sol";
import {Propose} from "bundle/textDAO/functions/onlyMember/Propose.sol";
import {Fork} from "bundle/textDAO/functions/onlyReps/Fork.sol";
import {Vote} from "bundle/textDAO/functions/onlyReps/Vote.sol";
import {RawFulfillRandomWords} from "bundle/textDAO/functions/onlyVrfCoordinator/RawFulfillRandomWords.sol";
import {ConfigOverrideProtected} from "bundle/textDAO/functions/protected/ConfigOverrideProtected.sol";
import {MemberJoinProtected} from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";
import {SaveTextProtected} from "bundle/textDAO/functions/protected/SaveTextProtected.sol";
import {SetConfigsProtected} from "bundle/textDAO/functions/protected/SetConfigsProtected.sol";
import {Execute} from "bundle/textDAO/functions/Execute.sol";
// import {Getter} from "bundle/textDAO/functions/Getter.sol";
import {Tally} from "bundle/textDAO/functions/Tally.sol";

import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {AddMember} from "bundle/textDAO/functions/_cheat/AddMember.sol";

import {TextDAOFacade} from "bundle/textDAO/interfaces/TextDAOFacade.sol";

/**
 * @title TextDAODeployer
 * @dev Library for deploying and initializing TextDAO contracts
 */
library TextDAODeployer {
    string internal constant BUNDLE_NAME = "TextDAO";

    /**
     * @dev Deploys the TextDAO contract
     * @param mc MCDevKit storage reference
     * @return textDAO Address of the deployed TextDAO proxy
     */
    function deploy(MCDevKit storage mc) internal returns(address textDAO) {
        mc.init(BUNDLE_NAME);
        _useMainFunctions(mc);
        mc.useFacade(address(new TextDAOFacade())); // for Etherscan proxy read/write

        return mc.deploy().toProxyAddress();
    }

    /**
     * @dev Deploys the TextDAO contract with cheat functions and initializes with an admin
     * @param mc MCDevKit storage reference
     * @param admin Address of the initial admin who can cheat
     * @return textDAO Address of the deployed TextDAO proxy
     */
    function deployWithCheat(MCDevKit storage mc, address admin) internal returns(address textDAO) {
        mc.init(BUNDLE_NAME);
        _useMainFunctions(mc);
        _useCheatFunctions(mc);
        mc.useFacade(address(new TextDAOFacade())); // for Etherscan proxy read/write

        Schema.Member[] memory _initialMembers = new Schema.Member[](1);
        _initialMembers[0] = Schema.Member({addr: admin, metadataURI: ""});

        return mc.deploy(
            abi.encodeCall(
                Initialize.initialize,
                (_initialMembers, _setupInitialConfig())
            )
        ).toProxyAddress();
    }

    /**
     * @dev Deploys the TextDAO contract with getter functions
     * @param mc MCDevKit storage reference
     * @return textDAO Address of the deployed TextDAO proxy
     */
    function deployWithGetter(MCDevKit storage mc) internal returns(address textDAO) {
        mc.init(BUNDLE_NAME);
        _useMainFunctions(mc);
        _useGetterFunctions(mc);
        mc.useFacade(address(new TextDAOFacade())); // for Etherscan proxy read/write

        return mc.deploy().toProxyAddress();
    }

    //=============================
    //      Helper Functions
    //=============================

    /**
     * @dev Sets up the main functions for the TextDAO
     * @param mc MCDevKit storage reference
     */
    function _useMainFunctions(MCDevKit storage mc) internal {
        mc.use("Clone", Clone.clone.selector, address(new Clone()));

        // TextDAO core functions
        mc.use("Initialize", Initialize.initialize.selector, address(new Initialize()));
        mc.use("Propose", Propose.propose.selector, address(new Propose()));
        mc.use("Fork", Fork.fork.selector, address(new Fork()));
        mc.use("Vote", Vote.vote.selector, address(new Vote()));
        mc.use("Tally", Tally.tally.selector, address(new Tally()));
        mc.use("Execute", Execute.execute.selector, address(new Execute()));

        // TextDAO protected functions
        mc.use("MemberJoinProtected", MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
        address saveText = address(new SaveTextProtected());
        mc.use("CreateText", SaveTextProtected.createText.selector, saveText);
        mc.use("UpdateText", SaveTextProtected.updateText.selector, saveText);
        mc.use("DeleteText", SaveTextProtected.deleteText.selector, saveText);
        // mc.use("SetConfigsProtected", SetConfigsProtected.setProposalsConfig.selector, address(new SetConfigsProtected()));
        // mc.use("ConfigOverrideProtected", ConfigOverrideProtected.overrideProposalsConfig.selector, address(new ConfigOverrideProtected()));
    }

    /**
     * @dev Sets up cheat functions for testing purposes
     * @param mc MCDevKit storage reference
     */
    function _useCheatFunctions(MCDevKit storage mc) internal {
        mc.use("AddMember", AddMember.addMembers.selector, address(new AddMember()));
    }

    /**
     * @dev Sets up getter functions (commented out in current implementation)
     * @param mc MCDevKit storage reference
     */
    function _useGetterFunctions(MCDevKit storage mc) internal {
        // address getter = address(new Getter());
        // mc.use("getProposal", Getter.getProposal.selector, getter);
        // mc.use("getProposalHeaders", Getter.getProposalHeaders.selector, getter);
        // // mc.use("getProposalCommand", Getter.getProposalCommand.selector, getter);
        // mc.use("getProposalsConfig", Getter.getProposalsConfig.selector, getter);
        // mc.use("getText", Getter.getText.selector, getter);
        // mc.use("getTexts", Getter.getTexts.selector, getter);
        // mc.use("getMember", Getter.getMember.selector, getter);
        // mc.use("getMembers", Getter.getMembers.selector, getter);
        // // mc.use("getVRFRequest", Getter.getVRFRequest.selector, getter);
        // // mc.use("getNextVRFId", Getter.getNextVRFId.selector, getter);
        // mc.use("getSubscriptionId", Getter.getSubscriptionId.selector, getter);
        // mc.use("getVRFConfig", Getter.getVRFConfig.selector, getter);
        // mc.use("getConfigOverride", Getter.getConfigOverride.selector, getter);
    }

    /**
     * @dev Sets up initial members for the TextDAO
     * @param initialMemberAddrs Array of initial member addresses
     * @return initialMembers Array of Schema.Member structs
     */
    function _setupInitialMembers(address[] memory initialMemberAddrs) internal pure returns(Schema.Member[] memory initialMembers) {
        initialMembers = new Schema.Member[](initialMemberAddrs.length);
        for (uint i; i < initialMemberAddrs.length; ++i) {
            initialMembers[i] = Schema.Member({addr: initialMemberAddrs[i], metadataURI: ""});
        }
    }

    /**
     * @dev Sets up initial configuration for the TextDAO
     * @return Schema.DeliberationConfig struct with initial configuration
     */
    function _setupInitialConfig() internal pure returns(Schema.DeliberationConfig memory) {
        return Schema.DeliberationConfig({
            expiryDuration: 7 days,
            snapInterval: 2 hours,
            repsNum: 100,
            quorumScore: 2
        });
    }
}
