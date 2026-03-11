---
name: xcrawl-map
description: Use this skill for Xcrawl map tasks, including site URL discovery, regex filtering, scope estimation, and crawl planning before full-site crawling.
allowed-tools: Bash(curl:*) Bash(python3:*) Bash(python:*) Bash(node:*) Bash(nodejs:*) Read Write Edit Grep
metadata: {"version":"1.0.0","openclaw":{"skillKey":"xcrawl-map","homepage":"https://www.xcrawl.com/","requires":{"env":["XCRAWL_API_KEY"],"anyBins":["curl","python3","python","node","nodejs"]},"primaryEnv":"XCRAWL_API_KEY"}}
---

# Xcrawl Map

## Overview

This skill uses Xcrawl Map API to discover URLs for a site.
Default behavior is raw passthrough: return upstream API response bodies as-is.

## When To Use

Trigger this skill when the user asks to:

- List URLs under a domain before crawling
- Estimate site size and discover high-value paths
- Filter URLs by regex patterns
- Decide whether to include subdomains or query-parameter URLs

## API Surface

- Start map task: `POST /v1/map`
- Base URL: `https://run.xcrawl.com`
- Required header: `Authorization: Bearer <XCRAWL_API_KEY>`

## API Reference

Detailed API parameter and response documentation has been moved to `references/api-parameters.md`.

Use this file when you need full field-level definitions, defaults, enums, and response schemas.

## Usage Examples

### Natural language examples

- "Map all URLs under this domain and return the raw API response."
- "Return only `/docs/` URLs with `limit=2000` and no summarization."

### Script-based examples

- Shell map request: `scripts/map_urls.sh`
- Python map request: `scripts/map_urls.py`
- Node map request: `scripts/map_urls.js`

Run examples:

```bash
./scripts/map_urls.sh --url "https://example.com" --filter "/docs/.*" --limit 2000
./scripts/map_urls.sh --payload-file ./my-map-request.json

python3 ./scripts/map_urls.py --payload-json '{"url":"https://example.com","filter":"/docs/.*","limit":3000,"include_subdomains":true,"ignore_query_parameters":false}'
node ./scripts/map_urls.js --payload-file ./my-map-request.json
```

For complex scope control, use `--payload-file` or `--payload-json`.

## Resource Directories

- `scripts/`: executable helpers for URL grouping and scope generation
- `references/`: path taxonomy, mapping policies, and integration notes
- `assets/`: reusable mapping templates and output artifacts

Use `references/` for deep docs and keep `SKILL.md` focused on decisions.

## Cross-Agent Adapter Contract

This skill is runtime-agnostic and should be integrated through an adapter.

Adapter input contract:

- `goal`: mapping objective (discovery, prioritization, pre-crawl planning)
- `inputs`: target site URL and optional domain context
- `constraints`: filter regex, limit, subdomain/query handling
- `credentials_ref`: reference to API key source (never hardcode secrets)
- `runtime_context`: runtime-specific metadata (OpenAI, Claude, OpenClaw, etc.)

Adapter output contract:

- `status`: `completed` or `failed`
- `request_payload`: exact request payload sent to Xcrawl
- `raw_response`: raw response body from `POST /v1/map`
- `error`: transport or API error details when failed

OpenClaw integration note:

- Keep the adapter responsible for task-envelope translation.
- Keep this skill responsible for Xcrawl API semantics and request design.

## Request Design Checklist

1. Confirm map scope.
- `url` is required.
- Clarify domain boundaries and allowed URL families.

2. Set precision controls.
- `filter` for regex-based inclusion.
- `limit` for bounded output size.
- `include_subdomains` and `ignore_query_parameters` based on use case.

3. Plan handoff target.
- Define whether output feeds `xcrawl-crawl`, `xcrawl-scrape`, or both.
- Call out URL groups that should be excluded from later crawling.

## Workflow

1. Restate mapping objective.
- Discovery only, selective crawl planning, or structure analysis.

2. Build and execute `POST /v1/map`.
- Keep filters explicit and reproducible.

3. Return raw API response directly.
- Do not synthesize URL-family summaries unless requested.

## Output Contract

Return:

- Endpoint used (`POST /v1/map`)
- `request_payload` used for the request
- Raw response body from map call
- Error details when request fails

Do not generate summaries unless the user explicitly requests a summary.

## Guardrails

- Do not claim full site coverage if `limit` is reached.
- Do not mix inferred URLs with returned URLs.
- Do not convert this skill into CLI command instructions.
- Do not hardcode provider-specific tool schemas in core logic.
