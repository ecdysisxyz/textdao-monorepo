import { ipfs, json, log } from "@graphprotocol/graph-ts";
import { Header } from "../../generated/schema";

export function saveHeaderMetadata(metadataCid: string, header: Header): void {
    if (!metadataCid) return;
    const metadata = ipfs.cat(metadataCid);
    if (!metadata) return;
    const obj = json.fromBytes(metadata).toObject();
    if (obj) {
        const title = obj.get("title");
        const body = obj.get("body");

        if (title) {
            header.title = title.toString();
        } else {
            log.info(
                "`title` field not found in the proposal header content",
                []
            );
        }
        if (body) {
            header.body = body.toString();
        } else {
            log.info(
                "`body` field not found in the proposal header content",
                []
            );
        }

        header.save();
    }
}
