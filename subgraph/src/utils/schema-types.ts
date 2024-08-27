import { Bytes, BigInt } from "@graphprotocol/graph-ts";

export class Action {
    funcSig: string;
    abiParams: Bytes;

    constructor(funcSig: string, abiParams: Bytes) {
        this.funcSig = funcSig;
        this.abiParams = abiParams;
    }
}

export class Vote {
    rankedHeaderIds: BigInt[];
    rankedCommandIds: BigInt[];

    constructor(rankedHeaderIds: BigInt[], rankedCommandIds: BigInt[]) {
        this.rankedHeaderIds = rankedHeaderIds;
        this.rankedCommandIds = rankedCommandIds;
    }
}
