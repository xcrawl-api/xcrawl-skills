# xcrawl-skills

Reusable Xcrawl skill definitions for multi-agent runtimes, focused on API-first web data workflows.
Canonical repository: `https://github.com/xcrawl-api/xcrawl-skills`

This repository contains skills only. It does not implement CLI behavior.
Skills are designed to run across different agent ecosystems, including OpenAI-based agents, Claude-based agents, and OpenClaw-style runtimes.

## Skill Catalog

- `xcrawl-scrape`: Single-URL extraction and structured data workflows
- `xcrawl-map`: Site URL discovery and scope planning workflows
- `xcrawl-crawl`: Bulk site crawling and async result handling workflows
- `xcrawl-search`: Query-based discovery with location/language controls

## Skill Usage Examples

- `xcrawl-scrape`: "Scrape this URL in sync mode and return markdown plus links."
- `xcrawl-map`: "Map only `/docs/` URLs under this domain with a max of 2000 links."
- `xcrawl-crawl`: "Run a bounded crawl (depth 2, limit 100) and poll until completed."
- `xcrawl-search`: "Search in US English for this query and return top 20 results."

Detailed cURL / Python / Node examples are split into each skill's `scripts/` directory and referenced from `skills/*/SKILL.md`.

## Cross-Agent Compatibility

Each skill should be executed through a runtime adapter layer.

1. Normalize input from the host runtime.

- Convert runtime-native task format into a shared contract:
- `goal`, `inputs`, `constraints`, `credentials_ref`, `runtime_context`

2. Execute Xcrawl API workflow through the skill.

- Keep business logic and API semantics inside `SKILL.md`.
- Do not couple core logic to a specific model provider.

3. Normalize output back to the host runtime.

- Return a stable structure:
- `status`
- `request_payload`
- `raw_response` (single endpoint) or `raw_create_response` + `raw_result_response` (async workflow)
- `task_ids` (optional)
- `error` (optional)

Default behavior is raw passthrough: return upstream API response bodies as-is. Only summarize when the user explicitly requests a summary.

### Runtime examples

- OpenAI/Codex: tool-driven orchestration with structured arguments
- Claude-style agents: natural-language planner with explicit request payload control
- OpenClaw-like runtimes: adapter translates OpenClaw task envelopes into the shared contract above

## Shared Xcrawl Conventions

- Base URL: `https://run.xcrawl.com`
- Auth header: `Authorization: Bearer <XCRAWL_API_KEY>`
- Main endpoints:
  - `POST /v1/scrape` and `GET /v1/scrape/{scrape_id}`
  - `POST /v1/map`
  - `POST /v1/crawl` and `GET /v1/crawl/{crawl_id}`
  - `POST /v1/search`
- Common output formats for scrape/crawl: `html`, `raw_html`, `markdown`, `links`, `summary`, `screenshot`, `json`

## Validation

Run validation for every skill:

```bash
VALIDATOR="${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py"
for d in skills/*; do
  python3 "$VALIDATOR" "$d"
done
```

Notes:

- `SKILL.md` files are provider-agnostic core behavior.
- `agents/openai.yaml` is UI metadata for OpenAI-style surfaces and is not the execution contract.
- Additional runtime metadata files can be added later without changing core skill behavior.

## Source References

- Repository: `https://github.com/xcrawl-api/xcrawl-skills`
- Product site: `https://www.xcrawl.com/`
