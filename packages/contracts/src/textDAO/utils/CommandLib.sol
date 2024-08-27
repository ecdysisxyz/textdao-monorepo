// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

/**
 * @title CommandLib v0.1.0
 */
library CommandLib {
    function createAction(Schema.Command storage cmd, string memory funcSig, bytes memory abiParams) internal returns(Schema.Action storage) {
        return cmd.actions.push() = Schema.Action({
            funcSig: funcSig,
            abiParams: abiParams
        });
    }

    function createMemberJoinAction(Schema.Command storage cmd, uint pid, Schema.Member[] memory candidates) internal returns(Schema.Action storage) {
        return createAction({
            cmd: cmd,
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(pid, candidates)
        });
    }

    // Member Management Actions

    function createAddMembersAction(Schema.Command storage cmd, uint pid, Schema.Member[] memory candidates) internal returns(Schema.Action storage) {
        return createAction({
            cmd: cmd,
            funcSig: "addMembers(uint256,(address,string)[])",
            abiParams: abi.encode(pid, candidates)
        });
    }

    function createUpdateMemberAction(Schema.Command storage cmd, uint memberId, string memory newMetadataCid) internal returns(Schema.Action storage) {
        return createAction({
            cmd: cmd,
            funcSig: "updateMember(uint256,string)",
            abiParams: abi.encode(memberId, newMetadataCid)
        });
    }

    function createRemoveMemberAction(Schema.Command storage cmd, uint pid, uint memberId) internal returns(Schema.Action storage) {
        return createAction({
            cmd: cmd,
            funcSig: "removeMember(uint256,uint256)",
            abiParams: abi.encode(pid, memberId)
        });
    }

    // Text Management Actions

    function createCreateTextAction(Schema.Command storage cmd, uint pid, string memory metadataCid) internal returns(Schema.Action storage) {
        return createAction({
            cmd: cmd,
            funcSig: "createText(uint256,string)",
            abiParams: abi.encode(pid, metadataCid)
        });
    }

    function createUpdateTextAction(Schema.Command storage cmd, uint pid, uint textId, string memory metadataCid) internal returns(Schema.Action storage) {
        return createAction({
            cmd: cmd,
            funcSig: "updateText(uint256,uint256,string)",
            abiParams: abi.encode(pid, textId, metadataCid)
        });
    }

    function createDeleteTextAction(Schema.Command storage cmd, uint pid, uint textId) internal returns(Schema.Action storage) {
        return createAction({
            cmd: cmd,
            funcSig: "deleteText(uint256,uint256)",
            abiParams: abi.encode(pid, textId)
        });
    }

    function calcSelector(Schema.Action memory action) internal pure returns(bytes4) {
        return bytes4(keccak256(bytes(action.funcSig)));
    }

    function calcCallData(Schema.Action memory action) internal pure returns(bytes memory) {
        return abi.encodePacked(calcSelector(action), action.abiParams);
    }

}


// Testing
import {Test} from "forge-std/Test.sol";

contract CommandLibTest is Test {
    using CommandLib for Schema.Command;

    Schema.Command private cmd;

    function setUp() public {
        // Setup is not needed for this library test
    }

    function test_createAction() public {
        string memory funcSig = "testFunc(uint256,string)";
        bytes memory abiParams = abi.encode(123, "test");

        Schema.Action storage action = cmd.createAction(funcSig, abiParams);

        assertEq(action.funcSig, funcSig);
        assertEq(action.abiParams, abiParams);
        assertEq(cmd.actions.length, 1);
    }

    function test_createMemberJoinAction() public {
        uint pid = 1;
        Schema.Member[] memory candidates = new Schema.Member[](1);
        candidates[0] = Schema.Member({addr: address(0x1234), metadataCid: "testCid"});

        Schema.Action storage action = cmd.createMemberJoinAction(pid, candidates);

        assertEq(action.funcSig, "memberJoin(uint256,(address,string)[])");
        assertEq(abi.decode(action.abiParams, (uint256)), pid);
        assertEq(cmd.actions.length, 1);
    }

    function test_createAddMembersAction() public {
        uint pid = 1;
        Schema.Member[] memory candidates = new Schema.Member[](1);
        candidates[0] = Schema.Member({addr: address(0x1234), metadataCid: "testCid"});

        Schema.Action storage action = cmd.createAddMembersAction(pid, candidates);

        assertEq(action.funcSig, "addMembers(uint256,(address,string)[])");
        assertEq(abi.decode(action.abiParams, (uint256)), pid);
        assertEq(cmd.actions.length, 1);
    }

    function test_createUpdateMemberAction() public {
        uint memberId = 1;
        string memory newMetadataCid = "newTestCid";

        Schema.Action storage action = cmd.createUpdateMemberAction(memberId, newMetadataCid);

        assertEq(action.funcSig, "updateMember(uint256,string)");
        (uint decodedMemberId, string memory decodedCid) = abi.decode(action.abiParams, (uint256, string));
        assertEq(decodedMemberId, memberId);
        assertEq(decodedCid, newMetadataCid);
        assertEq(cmd.actions.length, 1);
    }

    function test_createRemoveMemberAction() public {
        uint pid = 1;
        uint memberId = 2;

        Schema.Action storage action = cmd.createRemoveMemberAction(pid, memberId);

        assertEq(action.funcSig, "removeMember(uint256,uint256)");
        (uint decodedPid, uint decodedMemberId) = abi.decode(action.abiParams, (uint256, uint256));
        assertEq(decodedPid, pid);
        assertEq(decodedMemberId, memberId);
        assertEq(cmd.actions.length, 1);
    }

    function test_createCreateTextAction() public {
        uint pid = 1;
        string memory metadataCid = "testTextCid";

        Schema.Action storage action = cmd.createCreateTextAction(pid, metadataCid);

        assertEq(action.funcSig, "createText(uint256,string)");
        (uint decodedPid, string memory decodedCid) = abi.decode(action.abiParams, (uint256, string));
        assertEq(decodedPid, pid);
        assertEq(decodedCid, metadataCid);
        assertEq(cmd.actions.length, 1);
    }

    function test_createUpdateTextAction() public {
        uint pid = 1;
        uint textId = 2;
        string memory metadataCid = "updatedTextCid";

        Schema.Action storage action = cmd.createUpdateTextAction(pid, textId, metadataCid);

        assertEq(action.funcSig, "updateText(uint256,uint256,string)");
        (uint decodedPid, uint decodedTextId, string memory decodedCid) = abi.decode(action.abiParams, (uint256, uint256, string));
        assertEq(decodedPid, pid);
        assertEq(decodedTextId, textId);
        assertEq(decodedCid, metadataCid);
        assertEq(cmd.actions.length, 1);
    }

    function test_createDeleteTextAction() public {
        uint pid = 1;
        uint textId = 2;

        Schema.Action storage action = cmd.createDeleteTextAction(pid, textId);

        assertEq(action.funcSig, "deleteText(uint256,uint256)");
        (uint decodedPid, uint decodedTextId) = abi.decode(action.abiParams, (uint256, uint256));
        assertEq(decodedPid, pid);
        assertEq(decodedTextId, textId);
        assertEq(cmd.actions.length, 1);
    }

    function test_calcSelector() public pure {
        Schema.Action memory action = Schema.Action({
            funcSig: "testFunc(uint256,string)",
            abiParams: abi.encode(123, "test")
        });

        bytes4 selector = CommandLib.calcSelector(action);

        assertEq(selector, bytes4(keccak256(bytes(action.funcSig))));
    }

    function test_calcCallData() public pure {
        Schema.Action memory action = Schema.Action({
            funcSig: "testFunc(uint256,string)",
            abiParams: abi.encode(123, "test")
        });

        bytes memory callData = CommandLib.calcCallData(action);

        assertEq(callData, abi.encodePacked(CommandLib.calcSelector(action), action.abiParams));
    }
}
