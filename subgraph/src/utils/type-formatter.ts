import { BigInt, Address, Bytes } from "@graphprotocol/graph-ts";

// Utility function to convert an array of Address to a formatted string
export function formatAddressArray(addresses: Address[]): string {
    let addressStrings: string[] = [];
    for (let i = 0; i < addresses.length; i++) {
        addressStrings.push(addresses[i].toHexString());
    }
    return "[" + addressStrings.join(", ") + "]";
}

// Utility function to convert an array of BigInt to a formatted string using a given conversion function
export function formatBigIntIdArray(
    pid: BigInt,
    ids: BigInt[],
    conversionFunction: (pid: BigInt, id: BigInt) => string
): string {
    let idStrings: string[] = [];
    for (let i = 0; i < ids.length; i++) {
        idStrings.push(conversionFunction(pid, ids[i]));
    }
    return "[" + idStrings.join(", ") + "]";
}

export function formatBigIntArray(bigIntArray: BigInt[]): string {
    return "[" + bigIntArray.join(", ") + "]";
}

export function formatAddressArrayToBytesArray(
    addressArray: Address[]
): Bytes[] {
    let bytesArray: Array<Bytes> = [];
    for (let i = 0; i < addressArray.length; i++) {
        bytesArray.push(addressArray[i]);
    }
    return bytesArray;
}
