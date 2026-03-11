#!/usr/bin/env node
const fs = require("node:fs");

function parseArgs(argv) {
  const args = { _: [] };
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) {
      args._.push(token);
      continue;
    }
    const eqIndex = token.indexOf("=");
    if (eqIndex !== -1) {
      const key = token.slice(2, eqIndex);
      args[key] = token.slice(eqIndex + 1);
      continue;
    }
    const key = token.slice(2);
    const next = argv[i + 1];
    if (next && !next.startsWith("--")) {
      args[key] = next;
      i += 1;
    } else {
      args[key] = "true";
    }
  }
  return args;
}

function buildPayload(args) {
  if (args["payload-file"] && args["payload-json"]) {
    throw new Error("Use only one of --payload-file or --payload-json");
  }
  if (args["payload-file"]) {
    const content = fs.readFileSync(args["payload-file"], "utf8");
    return JSON.parse(content);
  }
  if (args["payload-json"]) {
    return JSON.parse(args["payload-json"]);
  }

  const url = args.url || args._[0] || "https://example.com";
  const formats = (args.formats || "markdown,links")
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);

  return {
    url,
    mode: "sync",
    output: { formats: formats.length ? formats : ["markdown", "links"] },
  };
}

async function main() {
  const apiKey = process.env.XCRAWL_API_KEY;
  if (!apiKey) {
    console.error("XCRAWL_API_KEY is required");
    process.exit(1);
  }

  const args = parseArgs(process.argv.slice(2));
  const payload = buildPayload(args);

  const resp = await fetch("https://run.xcrawl.com/v1/scrape", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  const text = await resp.text();
  process.stdout.write(`${text}\n`);
  if (!resp.ok) {
    process.exit(1);
  }
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
