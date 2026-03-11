---
name: xcrawl-crawl
description: Use this skill for Xcrawl crawl tasks, including bulk site crawling, crawler rule design, async status polling, and delivery of crawl output for downstream scrape and search workflows.
allowed-tools: Bash(curl:*) Bash(python3:*) Bash(python:*) Bash(node:*) Bash(nodejs:*) Read Write Edit Grep
metadata: {"version":"1.0.0","openclaw":{"skillKey":"xcrawl-crawl","homepage":"https://www.xcrawl.com/","requires":{"env":["XCRAWL_API_KEY"],"anyBins":["curl","python3","python","node","nodejs"]},"primaryEnv":"XCRAWL_API_KEY"}}
---

# Xcrawl Crawl

## Overview

This skill orchestrates full-site or scoped crawling with Xcrawl Crawl APIs.
Default behavior is raw passthrough: return upstream API response bodies as-is.

## When To Use

Trigger this skill when the user asks to:

- Crawl many pages from one entry URL
- Apply include/exclude rules and depth/limit controls
- Configure rendering, request, proxy, and output formats
- Monitor crawl progress and fetch final result by `crawl_id`

## API Surface

- Start crawl: `POST /v1/crawl`
- Read result: `GET /v1/crawl/{crawl_id}`
- Base URL: `https://run.xcrawl.com`
- Required header: `Authorization: Bearer <XCRAWL_API_KEY>`

## API Reference

Detailed API parameter and response documentation has been moved to `references/api-parameters.md`.

Use this file when you need full field-level definitions, defaults, enums, and response schemas.

## Usage Examples

### Natural language examples

- "Crawl this docs site with depth 2 and keep the full raw response payload."
- "Start an async crawl and return create/result responses without summarization."

### Script-based examples

- Shell create crawl task: `scripts/crawl_create.sh`
- Shell fetch crawl result: `scripts/crawl_result.sh`
- Python create and poll: `scripts/crawl_create_and_poll.py`
- Node create and poll: `scripts/crawl_create_and_poll.js`

Run examples:

```bash
./scripts/crawl_create.sh --url "https://example.com"
./scripts/crawl_create.sh --payload-file ./my-crawl-request.json
./scripts/crawl_result.sh --crawl-id "<crawl_id>"

python3 ./scripts/crawl_create_and_poll.py --url "https://example.com" --max-attempts 40 --interval 3
python3 ./scripts/crawl_create_and_poll.py --payload-json '{"url":"https://example.com","crawler":{"limit":300,"max_depth":3,"include":["/docs/.*"],"exclude":["/blog/.*"]},"request":{"locale":"ja-JP"},"output":{"formats":["markdown","links","json"]}}'

node ./scripts/crawl_create_and_poll.js --payload-file ./my-crawl-request.json
```

For complex crawler rules or locale/device/proxy settings, use `--payload-file` or `--payload-json`.

## Resource Directories

- `scripts/`: executable helpers for repeatable crawl and polling workflows
- `references/`: detailed crawler policy notes and API mappings
- `assets/`: templates and reusable files for downstream outputs

Keep heavy reference content in `references/` and keep `SKILL.md` procedural.

## Cross-Agent Adapter Contract

This skill is runtime-agnostic and should be integrated through an adapter.

Adapter input contract:

- `goal`: crawl objective and expected business outcome
- `inputs`: entry URL and optional seed context
- `constraints`: depth, limit, include/exclude patterns, policy constraints
- `credentials_ref`: reference to API key source (never hardcode secrets)
- `runtime_context`: runtime-specific metadata (OpenAI, Claude, OpenClaw, etc.)

Adapter output contract:

- `status`: `completed` or `failed`
- `request_payload`: exact request payload sent to Xcrawl
- `raw_create_response`: raw response body from `POST /v1/crawl`
- `raw_result_response`: raw response body from `GET /v1/crawl/{crawl_id}`
- `task_ids`: parsed IDs when available (for example `crawl_id`)
- `error`: transport or API error details when failed

OpenClaw integration note:

- Do not rely on provider-specific function-calling assumptions.
- Require explicit adapter mapping between OpenClaw task envelope and the contract above.

## Request Design Checklist

1. Scope the crawl precisely.
- `url` is required.
- `crawler.limit`, `crawler.max_depth`, `crawler.include`, `crawler.exclude`.
- Decide `include_entire_domain`, `include_subdomains`, `include_external_links`.

2. Configure page retrieval behavior.
- `request`: locale/device/cookies/headers/main-content preference.
- `js_render`: render strategy and viewport.
- `proxy`: location and sticky session when required.

3. Define output contract.
- `output.formats` (default is `["markdown"]`).
- Optional `summary`, `screenshot`, and structured `json` extraction.
- Optional async callback through `webhook`.

## Workflow

1. Confirm business objective and crawl boundary.
- What content is required, what content must be excluded, and what is the completion signal.

2. Draft a bounded crawl request.
- Prefer explicit limits and path constraints.
- Keep risky settings off unless explicitly requested.

3. Start crawl and capture task metadata.
- Record `crawl_id`, initial status, and request payload.

4. Poll `GET /v1/crawl/{crawl_id}` until terminal state.
- Track `pending`, `crawling`, `completed`, or `failed`.
- Stop polling on terminal status and return the raw result response.

5. Return raw create/result responses.
- Do not synthesize derived summaries unless explicitly requested.

## Output Contract

Return:

- Endpoint flow (`POST /v1/crawl` + `GET /v1/crawl/{crawl_id}`)
- `request_payload` used for the create request
- Raw response body from create call
- Raw response body from result call
- Error details when request fails

Do not generate summaries unless the user explicitly requests a summary.

## Guardrails

- Never run an unbounded crawl without explicit constraints.
- Do not present speculative page counts as final coverage.
- Do not produce CLI command flags; stay API-request oriented.
- Do not hardcode provider-specific tool schemas in core logic.
- Highlight policy, legal, or website-usage risks when relevant.
