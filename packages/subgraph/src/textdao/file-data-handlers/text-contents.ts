import { Bytes, dataSource, json, log } from "@graphprotocol/graph-ts";
import { TextContents } from "../../generated/schema";

export function handleTextContents(content: Bytes): void {
  const textContents = new TextContents(dataSource.stringParam());
  const obj = json.fromBytes(content).toObject();
  if (obj) {
    const title = obj.get("title");
    const body = obj.get("body");

    if (title) {
      textContents.title = title.toString();
      log.info("`title` added: ", [title.toString()]);
    } else {
      log.info("`title` field not found in the text content", []);
    }
    if (body) {
      textContents.body = body.toString();
      log.info("`body` added: ", [body.toString()]);
    } else {
      log.info("`body` field not found in the text content", []);
    }

    textContents.save();
  }
}
