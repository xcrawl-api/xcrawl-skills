#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scrape_sync.sh [--url URL] [--formats CSV]
  scrape_sync.sh --payload-file FILE
  scrape_sync.sh --payload-json JSON

Examples:
  ./scrape_sync.sh --url "https://example.com"
  ./scrape_sync.sh --formats "markdown,links,json"
  ./scrape_sync.sh --payload-file ./scrape-request.json
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

csv_to_json_array() {
  local csv="$1"
  local part trimmed output=""
  IFS=',' read -r -a parts <<< "$csv"
  for part in "${parts[@]}"; do
    trimmed="${part#"${part%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
    if [[ -z "$trimmed" ]]; then
      continue
    fi
    if [[ -n "$output" ]]; then
      output+=","
    fi
    output+="\"$(json_escape "$trimmed")\""
  done
  printf '[%s]' "$output"
}

if [[ -z "${XCRAWL_API_KEY:-}" ]]; then
  echo "XCRAWL_API_KEY is required" >&2
  exit 1
fi

URL="https://example.com"
FORMATS="markdown,links"
PAYLOAD_FILE=""
PAYLOAD_JSON=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)
      URL="${2:-}"
      shift 2
      ;;
    --formats)
      FORMATS="${2:-}"
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
  FORMATS_JSON="$(csv_to_json_array "$FORMATS")"
  PAYLOAD="$(cat <<JSON
{"url":"$(json_escape "$URL")","mode":"sync","output":{"formats":$FORMATS_JSON}}
JSON
)"
fi

curl -sS -X POST "https://run.xcrawl.com/v1/scrape" \
  -H "Authorization: Bearer ${XCRAWL_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
