---
name: xcrawl-scrape
description: Use this skill for Xcrawl scrape tasks, including single-URL fetch, format selection, sync or async execution, and JSON extraction with prompt or json_schema.
allowed-tools: Bash(curl:*) Bash(python3:*) Bash(python:*) Bash(node:*) Bash(nodejs:*) Read Write Edit Grep
metadata: {"version":"1.0.0","openclaw":{"skillKey":"xcrawl-scrape","homepage":"https://www.xcrawl.com/","requires":{"env":["XCRAWL_API_KEY"],"anyBins":["curl","python3","python","node","nodejs"]},"primaryEnv":"XCRAWL_API_KEY"}}
---

# Xcrawl Scrape

## Overview

This skill handles single-page extraction with Xcrawl Scrape APIs.
Default behavior is raw passthrough: return upstream API response bodies as-is.

## When To Use

Trigger this skill when the user asks to:

- Fetch one URL and return `markdown`, `html`, `links`, `summary`, or `screenshot`
- Extract structured JSON from one page using prompt-only or `json_schema`
- Choose between `mode=sync` and `mode=async`
- Poll scrape task status by `scrape_id`

## API Surface

- Start scrape: `POST /v1/scrape`
- Read async result: `GET /v1/scrape/{scrape_id}`
- Base URL: `https://run.xcrawl.com`
- Required header: `Authorization: Bearer <XCRAWL_API_KEY>`

## API Reference

Detailed API parameter and response documentation has been moved to `references/api-parameters.md`.

Use this file when you need full field-level definitions, defaults, enums, and response schemas.

## Usage Examples

### Natural language examples

- "Scrape `https://example.com` and return raw API response."
- "Run async scrape on this product page and keep all raw result fields."

### Script-based examples

- Shell sync request: `scripts/scrape_sync.sh`
- Shell async create: `scripts/scrape_async_create.sh`
- Shell async result fetch: `scripts/scrape_async_result.sh`
- Python sync request: `scripts/scrape_sync.py`
- Node sync request: `scripts/scrape_sync.js`

Run examples:

```bash
./scripts/scrape_sync.sh --url "https://example.com"
./scripts/scrape_sync.sh --payload-file ./my-scrape-request.json

./scripts/scrape_async_create.sh --url "https://example.com/product/1" --prompt "Extract title, price, currency, and locale."
./scripts/scrape_async_create.sh --payload-json '{"url":"https://example.com","mode":"async","request":{"locale":"de-DE","headers":{"Accept-Language":"de-DE"}},"output":{"formats":["json"]},"json":{"prompt":"Extract title and price."}}'
./scripts/scrape_async_result.sh --scrape-id "<scrape_id>"

python3 ./scripts/scrape_sync.py --payload-json '{"url":"https://example.com","mode":"sync","request":{"locale":"fr-FR"},"output":{"formats":["markdown","links","json"]},"json":{"prompt":"Extract title and publish date."}}'
node ./scripts/scrape_sync.js --payload-file ./my-scrape-request.json
```

For complex inputs (locale, device, headers, proxy, schema), use `--payload-file` or `--payload-json`.

## Resource Directories

- `scripts/`: executable helpers for repeatable scrape workflows
- `references/`: long-form docs, schemas, and domain notes loaded on demand
- `assets/`: templates and output resources used by generated artifacts

Keep detailed material in `references/` instead of overloading `SKILL.md`.

## Cross-Agent Adapter Contract

This skill is runtime-agnostic and should be integrated through an adapter.

Adapter input contract:

- `goal`: extraction objective and expected field-level outcome
- `inputs`: target URL and optional page context
- `constraints`: mode, output formats, schema strictness, quality thresholds
- `credentials_ref`: reference to API key source (never hardcode secrets)
- `runtime_context`: runtime-specific metadata (OpenAI, Claude, OpenClaw, etc.)

Adapter output contract:

- `status`: `completed` or `failed`
- `request_payload`: exact request payload sent to Xcrawl
- `raw_response`: raw response body for sync flow
- `raw_create_response` and `raw_result_response`: raw response bodies for async flow
- `task_ids`: parsed IDs when available (for example `scrape_id`)
- `error`: transport or API error details when failed

OpenClaw integration note:

- Keep extraction prompts and schema definitions provider-neutral.
- Let the OpenClaw adapter handle conversion from OpenClaw task objects to this contract.

## Request Design Checklist

1. Confirm target and execution mode.
- `url` is required.
- Use `mode=sync` for immediate results.
- Use `mode=async` for long-running pages or webhook workflows.

2. Configure page fetching behavior only when needed.
- `request`: `locale`, `device`, `cookies`, `headers`, `only_main_content`.
- `js_render`: `enabled`, `wait_until`, viewport.
- `proxy`: `location`, `sticky_session`.

3. Define output explicitly.
- `output.formats` defaults to `["markdown"]`.
- Add `json` when extraction is required.
- Add `screenshot` and choose `output.screenshot` when visual verification is required.

4. Define extraction contract when using JSON.
- `json.prompt` for flexible extraction.
- `json.json_schema` when strict structure is required.

## Workflow

1. Restate the user goal as an extraction contract.
- URL scope, required fields, accepted nulls, and precision expectations.

2. Build the scrape request body.
- Keep only necessary options.
- Prefer explicit `output.formats`.

3. Execute scrape and capture task metadata.
- Track `scrape_id`, `status`, and timestamps.
- If async, poll until `completed` or `failed`.

4. Return raw API responses directly.
- Do not synthesize or compress fields by default.
- Provide optional explanation only if the user asks for it.

## Output Contract

Return:

- Endpoint(s) used and mode (`sync` or `async`)
- `request_payload` used for the request
- Raw response body from each API call
- Error details when request fails

Do not generate summaries unless the user explicitly requests a summary.

## Guardrails

- Do not invent unsupported output fields.
- Do not switch to CLI command syntax or flags.
- Do not hardcode provider-specific tool schemas in core logic.
- Call out uncertainty when page structure is unstable.
