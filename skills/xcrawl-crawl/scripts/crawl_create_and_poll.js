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
    return JSON.parse(fs.readFileSync(args["payload-file"], "utf8"));
  }
  if (args["payload-json"]) {
    return JSON.parse(args["payload-json"]);
  }

  const formats = String(args.formats || "markdown")
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);

  return {
    url: args.url || args._[0] || "https://example.com",
    crawler: {
      limit: Number(args.limit || 100),
      max_depth: Number(args["max-depth"] || 2),
    },
    output: {
      formats: formats.length ? formats : ["markdown"],
    },
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
  const interval = Number(args.interval || 2);
  const maxAttempts = Number(args["max-attempts"] || 30);

  const createResp = await fetch("https://run.xcrawl.com/v1/crawl", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  const createText = await createResp.text();
  process.stdout.write(`${createText}\n`);
  if (!createResp.ok) {
    process.exit(1);
  }

  let createData;
  try {
    createData = JSON.parse(createText);
  } catch (err) {
    throw new Error(`create response is not JSON: ${err.message}`);
  }

  const crawlId = createData.crawl_id;
  if (!crawlId) {
    throw new Error("crawl_id missing in create response");
  }

  for (let i = 0; i < maxAttempts; i += 1) {
    const resultResp = await fetch(`https://run.xcrawl.com/v1/crawl/${crawlId}`, {
      headers: { Authorization: `Bearer ${apiKey}` },
    });

    const resultText = await resultResp.text();
    if (!resultResp.ok) {
      process.stdout.write(`${resultText}\n`);
      process.exit(1);
    }

    let resultData;
    try {
      resultData = JSON.parse(resultText);
    } catch (err) {
      throw new Error(`result response is not JSON: ${err.message}`);
    }

    const status = resultData.status;
    if (status === "completed" || status === "failed") {
      process.stdout.write(`${resultText}\n`);
      return;
    }

    if (i < maxAttempts - 1) {
      await new Promise((resolve) => setTimeout(resolve, interval * 1000));
    }
  }

  throw new Error(`polling timed out after ${maxAttempts} attempts; crawl_id=${crawlId}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
