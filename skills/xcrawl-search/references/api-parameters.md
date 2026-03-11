# Xcrawl Search API Parameters

This file contains the detailed request and response parameter definitions for this skill.

Source references:
- Internal docs: `xcrawl-doc/docs/doc/api-reference` (private repo)
- https://www.xcrawl.com/


### Request endpoint and headers

- Endpoint: `POST https://run.xcrawl.com/v1/search`
- Headers:
- `Content-Type: application/json`
- `Authorization: Bearer <api_key>`

### Request body: top-level fields

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `query` | string | Yes | - | Search query |
| `location` | string | No | `US` | Location (country/city/region name or ISO code; best effort) |
| `language` | string | No | `en` | Language (ISO 639-1) |
| `limit` | integer | No | `10` | Max results (`1-100`) |

### Response fields

| Field | Type | Description |
|---|---|---|
| `search_id` | string | Task ID |
| `endpoint` | string | Always `search` |
| `version` | string | Version |
| `status` | string | `completed` |
| `query` | string | Search query |
| `data` | object | Search result data |
| `started_at` | string | Start time (ISO 8601) |
| `ended_at` | string | End time (ISO 8601) |
| `total_credits_used` | integer | Total credits used |

`data` notes from current API reference:

- Concrete result schema is implementation-defined
- Includes billing fields like `credits_used` and `credits_detail`

