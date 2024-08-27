import { Bytes, dataSource, json, log } from "@graphprotocol/graph-ts";
import { HeaderContents } from "../../generated/schema";

export function handleHeaderContents(content: Bytes): void {
	const headerContents = new HeaderContents(dataSource.stringParam());
	const obj = json.fromBytes(content).toObject();
	if (obj) {
		const title = obj.get("title");
		const body = obj.get("body");

		if (title) {
			headerContents.title = title.toString();
			log.info("`title` added: ", [title.toString()]);
		} else {
			log.info("`title` field not found in the proposal header content", []);
		}
		if (body) {
			headerContents.body = body.toString();
			log.info("`body` added: ", [body.toString()]);
		} else {
			log.info("`body` field not found in the proposal header content", []);
		}

		headerContents.save();
	}
}
