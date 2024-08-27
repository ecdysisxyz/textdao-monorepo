import { Bytes, dataSource, json, log } from "@graphprotocol/graph-ts";
import { MemberInfo } from "../../generated/schema";

export function handleMemberInfo(content: Bytes): void {
	const memberInfo = new MemberInfo(dataSource.stringParam());
	const obj = json.fromBytes(content).toObject();
	if (obj) {
		const name = obj.get("name");
		const image = obj.get("image");
		const bio = obj.get("bio");

		if (name) {
			memberInfo.name = name.toString();
			log.info("`name` added: ", [name.toString()]);
		} else {
			log.warning("`name` field not found in the member content", []);
		}
		if (image) {
			memberInfo.image = image.toString();
			log.info("`image` added: ", [image.toString()]);
		} else {
			log.warning("`image` field not found in the member content", []);
		}
		if (bio) {
			memberInfo.bio = bio.toString();
			log.info("`bio` added: ", [bio.toString()]);
		} else {
			log.warning("`bio` field not found in the member content", []);
		}
	}

	memberInfo.save();
}
