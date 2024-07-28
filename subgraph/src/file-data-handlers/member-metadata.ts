import { json, ipfs, log } from "@graphprotocol/graph-ts";
import { Member } from "../../generated/schema";

export function saveMemberMetadata(metadataCid: string, member: Member): void {
    if (!metadataCid) return;
    const metadata = ipfs.cat(metadataCid);
    if (!metadata) return;
    const obj = json.fromBytes(metadata).toObject();
    if (obj) {
        const name = obj.get("name");
        const image = obj.get("image");
        const bio = obj.get("bio");
        if (name) {
            member.name = name.toString();
        } else {
            log.info("`name` field not found in the member content", []);
        }
        if (image) {
            member.image = image.toString();
        } else {
            log.info("`image` field not found in the member content", []);
        }
        if (bio) {
            member.bio = bio.toString();
        } else {
            log.info("`bio` field not found in the member content", []);
        }
    }
    member.save();
}
