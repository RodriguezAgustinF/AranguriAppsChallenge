import { execFileSync } from "node:child_process";
import { mkdirSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";

const mode = process.argv[2];

if (mode !== "--local" && mode !== "--linked") {
  throw new Error("Usá --local o --linked para elegir la base de datos.");
}

const outputPath = resolve("src/types/database.types.ts");
const temporaryPath = `${outputPath}.tmp`;
const executable = process.platform === "win32" ? "supabase.cmd" : "supabase";

try {
  const generatedTypes = execFileSync(
    executable,
    ["gen", "types", mode, "--lang", "typescript", "--schema", "public"],
    { encoding: "utf8" },
  );

  if (!generatedTypes.includes("export type Database")) {
    throw new Error("Supabase no devolvió una definición Database válida.");
  }

  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(temporaryPath, generatedTypes, "utf8");
  renameSync(temporaryPath, outputPath);
} finally {
  rmSync(temporaryPath, { force: true });
}
