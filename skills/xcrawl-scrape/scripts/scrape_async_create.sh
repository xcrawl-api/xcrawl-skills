#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scrape_async_create.sh [--url URL] [--prompt TEXT]
  scrape_async_create.sh --payload-file FILE
  scrape_async_create.sh --payload-json JSON

Examples:
  ./scrape_async_create.sh --url "https://example.com" --prompt "Extract title and price"
  ./scrape_async_create.sh --payload-file ./scrape-async-request.json
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
PROMPT="Extract title and price."
PAYLOAD_FILE=""
PAYLOAD_JSON=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)
      URL="${2:-}"
      shift 2
      ;;
    --prompt)
      PROMPT="${2:-}"
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
  PROMPT="${POSITIONAL[1]}"
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
{"url":"$(json_escape "$URL")","mode":"async","output":{"formats":["json"]},"json":{"prompt":"$(json_escape "$PROMPT")"}}
JSON
)"
fi

curl -sS -X POST "https://run.xcrawl.com/v1/scrape" \
  -H "Authorization: Bearer ${XCRAWL_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
