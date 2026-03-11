---
name: xcrawl-search
description: Use this skill for Xcrawl search tasks, including keyword search request design, location and language controls, result analysis, and follow-up crawl or scrape planning.
allowed-tools: Bash(curl:*) Bash(python3:*) Bash(python:*) Bash(node:*) Bash(nodejs:*) Read Write Edit Grep
metadata: {"version":"1.0.0","openclaw":{"skillKey":"xcrawl-search","homepage":"https://www.xcrawl.com/","requires":{"env":["XCRAWL_API_KEY"],"anyBins":["curl","python3","python","node","nodejs"]},"primaryEnv":"XCRAWL_API_KEY"}}
---

# Xcrawl Search

## Overview

This skill uses Xcrawl Search API to retrieve query-based results.
Default behavior is raw passthrough: return upstream API response bodies as-is.

## When To Use

Trigger this skill when the user asks to:

- Search by keyword before scraping or crawling targets
- Narrow search by `location` and `language`
- Get a bounded result set for lead discovery or research workflows
- Evaluate query quality and suggest query refinements

## API Surface

- Search endpoint: `POST /v1/search`
- Base URL: `https://run.xcrawl.com`
- Required header: `Authorization: Bearer <XCRAWL_API_KEY>`

## API Reference

Detailed API parameter and response documentation has been moved to `references/api-parameters.md`.

Use this file when you need full field-level definitions, defaults, enums, and response schemas.

## Usage Examples

### Natural language examples

- "Search for AI crawling APIs in US English and return the raw API response."
- "Find pricing pages for web scraping services with `location=DE` and `language=de`."

### Script-based examples

- Shell search request: `scripts/search_query.sh`
- Python search request: `scripts/search_query.py`
- Node search request: `scripts/search_query.js`

Run examples:

```bash
./scripts/search_query.sh --query "AI web crawler API" --location "US" --language "en" --limit 20
./scripts/search_query.sh --payload-file ./my-search-request.json

python3 ./scripts/search_query.py --payload-json '{"query":"web scraping pricing","location":"DE","language":"de","limit":30}'
node ./scripts/search_query.js --payload-file ./my-search-request.json
```

For complex parameters, use `--payload-file` or `--payload-json`.

## Resource Directories

- `scripts/`: executable helpers for query experiments and result triage
- `references/`: ranking heuristics and query strategy notes
- `assets/`: reusable templates for search analysis outputs

Put large guidance in `references/` to keep `SKILL.md` concise and actionable.

## Cross-Agent Adapter Contract

This skill is runtime-agnostic and should be integrated through an adapter.

Adapter input contract:

- `goal`: search intent and downstream usage goal
- `inputs`: user query and optional domain/topic context
- `constraints`: location, language, limit, quality expectations
- `credentials_ref`: reference to API key source (never hardcode secrets)
- `runtime_context`: runtime-specific metadata (OpenAI, Claude, OpenClaw, etc.)

Adapter output contract:

- `status`: `completed` or `failed`
- `request_payload`: exact request payload sent to Xcrawl
- `raw_response`: raw response body from `POST /v1/search`
- `error`: transport or API error details when failed

OpenClaw integration note:

- Keep search request design independent from provider-specific tool schemas.
- Use the adapter to map OpenClaw envelopes to the shared contract above.

## Request Design Checklist

1. Confirm search intent.
- Informational lookup, candidate site discovery, or competitive scan.

2. Set query controls explicitly.
- `query` is required.
- Optional: `location`, `language`, `limit`.
- Use advanced options only when requested and supported by current docs.

3. Plan downstream handoff.
- Determine whether top results should be mapped, crawled, or scraped directly.

## Workflow

1. Rewrite the request as a clear search objective.
- Include entity, geography, language, and freshness intent.

2. Build and execute `POST /v1/search`.
- Keep request explicit and deterministic.

3. Return raw API response directly.
- Do not synthesize relevance summaries unless requested.

## Output Contract

Return:

- Endpoint used (`POST /v1/search`)
- `request_payload` used for the request
- Raw response body from search call
- Error details when request fails

Do not generate summaries unless the user explicitly requests a summary.

## Guardrails

- Do not claim ranking guarantees that the API does not expose.
- Do not fabricate unavailable filters or response fields.
- Do not output CLI syntax; stay API-request oriented.
- Do not hardcode provider-specific tool schemas in core logic.
