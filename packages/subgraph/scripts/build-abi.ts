import { execSync } from "child_process";
import { existsSync } from "fs";
import { join } from "path";

const contractPath = join(__dirname, "../../contracts/out/TextDAOEvents.sol/TextDAOEvents.json");

if (!existsSync(contractPath)) {
  console.log("TextDAOEvents.json not found. Running forge build...");
  try {
    execSync("cd ../contracts && forge build", { stdio: "inherit" });
    console.log("forge build completed successfully.");
  } catch (error) {
    console.error("Error running forge build:", error);
    process.exit(1);
  }
} else {
  console.log("TextDAOEvents.json found. Skipping forge build.");
}
