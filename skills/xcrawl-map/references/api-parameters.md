# Xcrawl Map API Parameters

This file contains the detailed request and response parameter definitions for this skill.

Source references:
- Internal docs: `xcrawl-doc/docs/doc/api-reference` (private repo)
- https://www.xcrawl.com/


### Request endpoint and headers

- Endpoint: `POST https://run.xcrawl.com/v1/map`
- Headers:
- `Content-Type: application/json`
- `Authorization: Bearer <api_key>`

### Request body: top-level fields

| Field | Type | Required | Default | Description |
|---|---|---:|---|---|
| `url` | string | Yes | - | Site entry URL |
| `filter` | string | No | - | Regex filter for URLs |
| `limit` | integer | No | `5000` | Max URLs (up to `100000`) |
| `include_subdomains` | boolean | No | `true` | Include subdomains |
| `ignore_query_parameters` | boolean | No | `true` | Ignore URLs with query parameters |

### Response fields

| Field | Type | Description |
|---|---|---|
| `map_id` | string | Task ID |
| `endpoint` | string | Always `map` |
| `version` | string | Version |
| `status` | string | `completed` |
| `url` | string | Entry URL |
| `data` | object | URL list data |
| `started_at` | string | Start time (ISO 8601) |
| `ended_at` | string | End time (ISO 8601) |
| `total_credits_used` | integer | Total credits used |

`data` fields:

- `links`: URL list
- `total_links`: URL count
- `credits_used`: credits used
- `credits_detail`: credit breakdown

