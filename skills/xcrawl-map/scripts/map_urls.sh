#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  map_urls.sh [--url URL] [--filter REGEX] [--limit N] [--include-subdomains true|false] [--ignore-query-parameters true|false]
  map_urls.sh --payload-file FILE
  map_urls.sh --payload-json JSON

Examples:
  ./map_urls.sh --url "https://example.com" --filter "/docs/.*" --limit 2000
  ./map_urls.sh --payload-file ./map-request.json
USAGE
}

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

if [[ -z "${XCRAWL_API_KEY:-}" ]]; then
  echo "XCRAWL_API_KEY is required" >&2
  exit 1
fi

URL="https://example.com"
FILTER="/docs/.*"
LIMIT="2000"
INCLUDE_SUBDOMAINS="false"
IGNORE_QUERY_PARAMETERS="true"
PAYLOAD_FILE=""
PAYLOAD_JSON=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)
      URL="${2:-}"
      shift 2
      ;;
    --filter)
      FILTER="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    --include-subdomains)
      INCLUDE_SUBDOMAINS="${2:-}"
      shift 2
      ;;
    --ignore-query-parameters)
      IGNORE_QUERY_PARAMETERS="${2:-}"
      shift 2
      ;;
    --payload-file)
      PAYLOAD_FILE="${2:-}"
      shift 2
      ;;
    --payload-json)
      PAYLOAD_JSON="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ ${#POSITIONAL[@]} -gt 0 ]]; then
  URL="${POSITIONAL[0]}"
fi
if [[ ${#POSITIONAL[@]} -gt 1 ]]; then
  FILTER="${POSITIONAL[1]}"
fi
if [[ ${#POSITIONAL[@]} -gt 2 ]]; then
  LIMIT="${POSITIONAL[2]}"
fi

if [[ -n "$PAYLOAD_FILE" && -n "$PAYLOAD_JSON" ]]; then
  echo "Use only one of --payload-file or --payload-json" >&2
  exit 1
fi

if [[ -n "$PAYLOAD_FILE" ]]; then
  if [[ ! -f "$PAYLOAD_FILE" ]]; then
    echo "Payload file not found: $PAYLOAD_FILE" >&2
    exit 1
  fi
  PAYLOAD="$(cat "$PAYLOAD_FILE")"
elif [[ -n "$PAYLOAD_JSON" ]]; then
  PAYLOAD="$PAYLOAD_JSON"
else
  case "$INCLUDE_SUBDOMAINS" in
    true|false) ;;
    *) echo "--include-subdomains must be true or false" >&2; exit 1 ;;
  esac
  case "$IGNORE_QUERY_PARAMETERS" in
    true|false) ;;
    *) echo "--ignore-query-parameters must be true or false" >&2; exit 1 ;;
  esac

  PAYLOAD="$(cat <<JSON
{"url":"$(json_escape "$URL")","filter":"$(json_escape "$FILTER")","limit":${LIMIT},"include_subdomains":${INCLUDE_SUBDOMAINS},"ignore_query_parameters":${IGNORE_QUERY_PARAMETERS}}
JSON
)"
fi

curl -sS -X POST "https://run.xcrawl.com/v1/map" \
  -H "Authorization: Bearer ${XCRAWL_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
