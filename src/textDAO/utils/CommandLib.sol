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
