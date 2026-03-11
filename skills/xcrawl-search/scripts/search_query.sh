#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  search_query.sh [--query TEXT] [--location CODE] [--language CODE] [--limit N]
  search_query.sh --payload-file FILE
  search_query.sh --payload-json JSON

Examples:
  ./search_query.sh --query "AI web crawler API" --location "US" --language "en" --limit 20
  ./search_query.sh --payload-file ./search-request.json
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

QUERY="AI web crawler API"
LOCATION="US"
LANGUAGE="en"
LIMIT="20"
PAYLOAD_FILE=""
PAYLOAD_JSON=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --query)
      QUERY="${2:-}"
      shift 2
      ;;
    --location)
      LOCATION="${2:-}"
      shift 2
      ;;
    --language)
      LANGUAGE="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
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
  QUERY="${POSITIONAL[0]}"
fi
if [[ ${#POSITIONAL[@]} -gt 1 ]]; then
  LOCATION="${POSITIONAL[1]}"
fi
if [[ ${#POSITIONAL[@]} -gt 2 ]]; then
  LANGUAGE="${POSITIONAL[2]}"
fi
if [[ ${#POSITIONAL[@]} -gt 3 ]]; then
  LIMIT="${POSITIONAL[3]}"
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
  PAYLOAD="$(cat <<JSON
{"query":"$(json_escape "$QUERY")","location":"$(json_escape "$LOCATION")","language":"$(json_escape "$LANGUAGE")","limit":${LIMIT}}
JSON
)"
fi

curl -sS -X POST "https://run.xcrawl.com/v1/search" \
  -H "Authorization: Bearer ${XCRAWL_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
