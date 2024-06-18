// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {Getter} from "bundle/textDAO/functions/Getter.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";

contract GetterTest is MCTest {

    function setUp() public {
        address getter = address(new Getter());
        _use(Getter.getProposal.selector, getter);
        _use(Getter.getProposalHeaders.selector, getter);
        _use(Getter.getProposalCommand.selector, getter);
        _use(Getter.getProposalsConfig.selector, getter);
        _use(Getter.getText.selector, getter);
        _use(Getter.getNextTextId.selector, getter);
        _use(Getter.getMember.selector, getter);
        _use(Getter.getMembers.selector, getter);
        _use(Getter.getVRFRequest.selector, getter);
        _use(Getter.getNextVRFId.selector, getter);
        _use(Getter.getSubscriptionId.selector, getter);
        _use(Getter.getVRFConfig.selector, getter);
        _use(Getter.getConfigOverride.selector, getter);
    }

    function test_Proposals_success() public {
        Schema.DAOState storage $ = Storage.DAOState();
        $.proposals.push();
        Schema.Proposal storage $proposal = $.proposals.push();
        $proposal.headers.push();
        $proposal.cmds.push().actions.push();
        $proposal.proposalMeta.currentScore = 1;
        $.config.expiryDuration = 1;

        Getter.ProposalInfo memory proposalInfo = Getter(address(this)).getProposal(1);
        assertEq(proposalInfo.proposalMeta.currentScore, 1);

        Schema.Header[] memory headers = Getter(address(this)).getProposalHeaders(1);
        assertEq(headers.length, 1);

        Schema.Command memory cmd = Getter(address(this)).getProposalCommand(1, 0);
        assertEq(cmd.actions.length, 1);

        Schema.DeliberationConfig memory resProposalsConfig = Getter(address(this)).getProposalsConfig();
        assertEq(resProposalsConfig.expiryDuration, 1);
    }

    function test_Texts_success() public {
        Schema.TextSaveProtectedStorage storage $ = Storage.$Texts();

        $.texts[1].id = 1;
        $.nextTextId = 1;

        Schema.Text memory resText = Getter(address(this)).getText(1);
        assertEq(resText.id, 1);

        uint resNextTextId = Getter(address(this)).getNextTextId();
        assertEq(resNextTextId, 1);
    }

    function test_Members_success() public {
        Schema.Members storage $ = Storage.Members();

        string memory _metadata = "pseudo metadata";
        $.members.push().metadataURI = _metadata;

        Schema.Member memory resMember = Getter(address(this)).getMember(0);
        assertEq(
            keccak256(abi.encode(resMember.metadataURI)),
            keccak256(abi.encode(_metadata))
        );

        Schema.Member[] memory _members = Getter(address(this)).getMembers();
        assertEq(_members.length, 1);
    }

    function test_VRF_success() public {
        Schema.VRFStorage storage $ = Storage.$VRF();

        $.requests[1].requestId = 1;
        $.nextId = 1;
        $.subscriptionId = 1;
        $.config.vrfCoordinator = address(1);

        Schema.Request memory resRequest = Getter(address(this)).getVRFRequest(1);
        assertEq(resRequest.requestId, 1);

        uint resNextVRFId = Getter(address(this)).getNextVRFId();
        assertEq(resNextVRFId, 1);

        uint resSubscriptionIdId = Getter(address(this)).getSubscriptionId();
        assertEq(resSubscriptionIdId, 1);

        Schema.VRFConfig memory resVRFConfig = Getter(address(this)).getVRFConfig();
        assertEq(resVRFConfig.vrfCoordinator, address(1));
    }

    function test_ConfigOverride_success() public {
        Schema.ConfigOverrideStorage storage $ = Storage.$ConfigOverride();

        $.overrides[bytes4(uint32(1))].quorumScore = 1;

        Schema.ConfigOverride memory resConfigOverride = Getter(address(this)).getConfigOverride(bytes4(uint32(1)));
        assertEq(resConfigOverride.quorumScore, 1);
    }
}
