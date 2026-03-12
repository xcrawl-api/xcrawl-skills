# XCrawl Skills

Reusable XCrawl skill definitions for multi-agent runtimes, focused on API-first web data workflows.
Canonical repository: `https://github.com/xcrawl-api/xcrawl-skills`

English | [中文](README.zh-CN.md)

## What Is XCrawl

XCrawl is a web data infrastructure product for search, scraping, URL mapping, and site crawling.
This repository provides production-oriented skill definitions that help agents call XCrawl APIs consistently.

## What This Repository Provides

- Ready-to-use skills for common XCrawl workflows
- API-oriented instructions with request/response parameter documentation
- cURL and Node examples suitable for runtime execution
- A consistent contract for multi-agent orchestration

## Skill Catalog

- `xcrawl-scrape`: Single-URL extraction and structured data workflows
- `xcrawl-map`: Site URL discovery and scope planning workflows
- `xcrawl-crawl`: Bulk site crawling and async result handling workflows
- `xcrawl-search`: Query-based discovery with location/language controls

## Quick Start

### 1. Prerequisites

- An XCrawl API key
- Register at `https://dash.xcrawl.com/` and activate the free `1000` credits plan
- Runtime binaries: `curl` and `node`
- Access to this repository

### 2. Configure Local API Key

Create local config file:

Path: `~/.xcrawl/config.json`

```json
{
  "XCRAWL_API_KEY": "<your_api_key>"
}
```

Skills in this repo are designed to read `XCRAWL_API_KEY` from this local file.

### 3. Choose a Skill

Open one of:

- `skills/xcrawl-scrape/SKILL.md`
- `skills/xcrawl-map/SKILL.md`
- `skills/xcrawl-crawl/SKILL.md`
- `skills/xcrawl-search/SKILL.md`

Each skill includes:

- Applicable scenarios
- Request parameters
- Response parameters
- cURL / Node examples

### 4. Run Requests

Use the examples in each `SKILL.md` directly, then adapt request payloads for your business scenario.

## Example User Intents

- "Scrape this page in sync mode and return markdown + links."
- "Map only `/docs/` URLs under this domain with a limit of 2000."
- "Start a bounded crawl (depth 2, limit 100) and poll until completed."
- "Search in US English and return top 20 results for this query."

## Cross-Agent Contract

Each skill can be executed through a runtime adapter layer.

- Input normalization: `goal`, `inputs`, `constraints`, `credentials_ref`, `runtime_context`
- Output normalization: `status`, `request_payload`, `raw_response` or async pair, `task_ids`, `error`

Default behavior is raw passthrough: return upstream API response bodies as-is.

## Shared XCrawl Conventions

- Base URL: `https://run.xcrawl.com`
- Local config file: `~/.xcrawl/config.json`
- API key field in local config: `XCRAWL_API_KEY`
- Auth header: `Authorization: Bearer <XCRAWL_API_KEY>`
- Main endpoints:
  - `POST /v1/scrape` and `GET /v1/scrape/{scrape_id}`
  - `POST /v1/map`
  - `POST /v1/crawl` and `GET /v1/crawl/{crawl_id}`
  - `POST /v1/search`

## Support

- [XCrawl Homepage](https://www.xcrawl.com/)
- [XCrawl Documentation](https://docs.xcrawl.com/)
