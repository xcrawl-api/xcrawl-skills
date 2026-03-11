# Xcrawl Scrape API Parameters

This file contains the detailed request and response parameter definitions for this skill.

Source references:
- Internal docs: `xcrawl-doc/docs/doc/api-reference` (private repo)
- https://www.xcrawl.com/


### Request endpoint and headers

- Endpoint: `POST https://run.xcrawl.com/v1/scrape`
- Headers:
- `Content-Type: application/json`
- `Authorization: Bearer <api_key>`

### Request body: top-level fields

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `url` | string | Yes | - | Target URL |
| `mode` | string | No | `sync` | `sync` or `async` |
| `proxy` | object | No | - | Proxy config |
| `request` | object | No | - | Request config |
| `js_render` | object | No | - | JS rendering config |
| `output` | object | No | - | Output config |
| `webhook` | object | No | - | Async webhook config (`mode=async`) |

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

#### Sync create response (`mode=sync`)

| Field | Type | Description |
|---|---|---|
| `scrape_id` | string | Task ID |
| `endpoint` | string | Always `scrape` |
| `version` | string | Version |
| `status` | string | `completed` / `failed` |
| `url` | string | Target URL |
| `data` | object | Result data |
| `started_at` | string | Start time (ISO 8601) |
| `ended_at` | string | End time (ISO 8601) |
| `total_credits_used` | integer | Total credits used |

`data` fields (based on `output.formats`):

- `html`, `raw_html`, `markdown`, `links`, `summary`, `screenshot`, `json`
- `metadata` (page metadata)
- `traffic_bytes`
- `credits_used`
- `credits_detail`

`credits_detail` fields:

| Field | Type | Description |
|---|---|---|
| `base_cost` | integer | Base scrape cost |
| `traffic_cost` | integer | Traffic cost |
| `json_extract_cost` | integer | JSON extraction cost |

#### Async create response (`mode=async`)

| Field | Type | Description |
|---|---|---|
| `scrape_id` | string | Task ID |
| `endpoint` | string | Always `scrape` |
| `version` | string | Version |
| `status` | string | Always `pending` |

#### Async result response (`GET /v1/scrape/{scrape_id}`)

| Field | Type | Description |
|---|---|---|
| `scrape_id` | string | Task ID |
| `endpoint` | string | Always `scrape` |
| `version` | string | Version |
| `status` | string | `pending` / `crawling` / `completed` / `failed` |
| `url` | string | Target URL |
| `data` | object | Same shape as sync `data` |
| `started_at` | string | Start time (ISO 8601) |
| `ended_at` | string | End time (ISO 8601) |

