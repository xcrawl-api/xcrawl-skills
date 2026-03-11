# Xcrawl Crawl API Parameters

This file contains the detailed request and response parameter definitions for this skill.

Source references:
- Internal docs: `xcrawl-doc/docs/doc/api-reference` (private repo)
- https://www.xcrawl.com/


### Request endpoint and headers

- Endpoint: `POST https://run.xcrawl.com/v1/crawl`
- Headers:
- `Content-Type: application/json`
- `Authorization: Bearer <api_key>`

### Request body: top-level fields

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `url` | string | Yes | - | Site entry URL |
| `crawler` | object | No | - | Crawler config |
| `proxy` | object | No | - | Proxy config |
| `request` | object | No | - | Request config |
| `js_render` | object | No | - | JS rendering config |
| `output` | object | No | - | Output config |
| `webhook` | object | No | - | Async callback config |

### `crawler`

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `limit` | integer | No | `100` | Max pages |
| `include` | string[] | No | - | Include only matching URLs (regex supported) |
| `exclude` | string[] | No | - | Exclude matching URLs (regex supported) |
| `max_depth` | integer | No | `3` | Max depth from entry URL |
| `include_entire_domain` | boolean | No | `false` | Crawl full site instead of only subpaths |
| `include_subdomains` | boolean | No | `false` | Include subdomains |
| `include_external_links` | boolean | No | `false` | Include external links |
| `sitemaps` | boolean | No | `true` | Use site sitemap |

### `proxy`

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `location` | string | No | `US` | ISO-3166-1 alpha-2 country code, e.g. `US` / `JP` / `SG` |
| `sticky_session` | string | No | Auto-generated | Sticky session ID; same ID attempts to reuse exit |

### `request`

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `locale` | string | No | `en-US,en;q=0.9` | Affects `Accept-Language` |
| `device` | string | No | `desktop` | `desktop` / `mobile`; affects UA and viewport |
| `cookies` | object map | No | - | Cookie key/value pairs |
| `headers` | object map | No | - | Header key/value pairs |
| `only_main_content` | boolean | No | `true` | Return main content only |
| `block_ads` | boolean | No | `true` | Attempt to block ad resources |
| `skip_tls_verification` | boolean | No | `true` | Skip TLS verification |

### `js_render`

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `enabled` | boolean | No | `true` | Enable browser rendering |
| `wait_until` | string | No | `load` | `load` / `domcontentloaded` / `networkidle` |
| `viewport.width` | integer | No | - | Viewport width (desktop `1920`, mobile `402`) |
| `viewport.height` | integer | No | - | Viewport height (desktop `1080`, mobile `874`) |

### `output`

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `formats` | string[] | No | `["markdown"]` | Output formats |
| `screenshot` | string | No | `viewport` | `full_page` / `viewport` (only if `formats` includes `screenshot`) |
| `json.prompt` | string | No | - | Extraction prompt |
| `json.json_schema` | object | No | - | JSON Schema |

`output.formats` enum:

- `html`
- `raw_html`
- `markdown`
- `links`
- `summary`
- `screenshot`
- `json`

### `webhook`

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `url` | string | No | - | Callback URL |
| `headers` | object map | No | - | Custom callback headers |
| `events` | string[] | No | `["started","completed","failed"]` | Events: `started` / `completed` / `failed` |

### Response fields

#### Create response (`POST /v1/crawl`)

| Field | Type | Description |
|---|---|---|
| `crawl_id` | string | Task ID |
| `endpoint` | string | Always `crawl` |
| `version` | string | Version |
| `status` | string | Always `pending` |

#### Result response (`GET /v1/crawl/{crawl_id}`)

| Field | Type | Description |
|---|---|---|
| `crawl_id` | string | Task ID |
| `endpoint` | string | Always `crawl` |
| `version` | string | Version |
| `status` | string | `pending` / `crawling` / `completed` / `failed` |
| `url` | string | Entry URL |
| `data` | object[] | Per-page result array |
| `started_at` | string | Start time (ISO 8601) |
| `ended_at` | string | End time (ISO 8601) |
| `total_credits_used` | integer | Total credits used |

`data[]` fields follow `output.formats`:

- `html`, `raw_html`, `markdown`, `links`, `summary`, `screenshot`, `json`
- `metadata` (page metadata)
- `traffic_bytes`
- `credits_used`
- `credits_detail`

