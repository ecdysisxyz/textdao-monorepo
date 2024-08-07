import { ipfs, json, log } from "@graphprotocol/graph-ts";
import { Text } from "../../generated/schema";

export function saveTextMetadata(metadataCid: string, text: Text): void {
	if (!metadataCid) return;
	const metadata = ipfs.cat(metadataCid);
	if (!metadata) return;
	const obj = json.fromBytes(metadata).toObject();
	if (obj) {
		const title = obj.get("title");
		const body = obj.get("body");

		if (title) {
			text.title = title.toString();
			log.info("`title` added: ", [title.toString()]);
		} else {
			log.info("`title` field not found in the text content", []);
		}
		if (body) {
			text.body = body.toString();
			log.info("`body` added: ", [body.toString()]);
		} else {
			log.info("`body` field not found in the text content", []);
		}

		text.save();
	}
}
