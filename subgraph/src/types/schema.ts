import { Bytes } from "@graphprotocol/graph-ts";

export class Action {
    funcSig: string;
    abiParams: Bytes;

    constructor(funcSig: string, abiParams: Bytes) {
        this.funcSig = funcSig;
        this.abiParams = abiParams;
    }
}
