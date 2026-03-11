#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  crawl_create.sh [--url URL] [--limit N] [--max-depth N] [--include CSV] [--exclude CSV] [--formats CSV]
                [--include-entire-domain true|false] [--include-subdomains true|false] [--include-external-links true|false]
  crawl_create.sh --payload-file FILE
  crawl_create.sh --payload-json JSON

Examples:
  ./crawl_create.sh --url "https://example.com" --limit 100 --max-depth 2
  ./crawl_create.sh --payload-file ./crawl-request.json
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
LIMIT="100"
MAX_DEPTH="2"
INCLUDE_PATTERNS="/docs/.*"
EXCLUDE_PATTERNS="/blog/.*"
FORMATS="markdown,links"
INCLUDE_ENTIRE_DOMAIN="false"
INCLUDE_SUBDOMAINS="false"
INCLUDE_EXTERNAL_LINKS="false"
PAYLOAD_FILE=""
PAYLOAD_JSON=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)
      URL="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    --max-depth)
      MAX_DEPTH="${2:-}"
      shift 2
      ;;
    --include)
      INCLUDE_PATTERNS="${2:-}"
      shift 2
      ;;
    --exclude)
      EXCLUDE_PATTERNS="${2:-}"
      shift 2
      ;;
    --formats)
      FORMATS="${2:-}"
      shift 2
      ;;
    --include-entire-domain)
      INCLUDE_ENTIRE_DOMAIN="${2:-}"
      shift 2
      ;;
    --include-subdomains)
      INCLUDE_SUBDOMAINS="${2:-}"
      shift 2
      ;;
    --include-external-links)
      INCLUDE_EXTERNAL_LINKS="${2:-}"
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
  for flag in "$INCLUDE_ENTIRE_DOMAIN" "$INCLUDE_SUBDOMAINS" "$INCLUDE_EXTERNAL_LINKS"; do
    case "$flag" in
      true|false) ;;
      *)
        echo "Boolean flags must be true or false" >&2
        exit 1
        ;;
    esac
  done

  INCLUDE_JSON="$(csv_to_json_array "$INCLUDE_PATTERNS")"
  EXCLUDE_JSON="$(csv_to_json_array "$EXCLUDE_PATTERNS")"
  FORMATS_JSON="$(csv_to_json_array "$FORMATS")"

  PAYLOAD="$(cat <<JSON
{"url":"$(json_escape "$URL")","include_entire_domain":${INCLUDE_ENTIRE_DOMAIN},"include_subdomains":${INCLUDE_SUBDOMAINS},"include_external_links":${INCLUDE_EXTERNAL_LINKS},"crawler":{"limit":${LIMIT},"max_depth":${MAX_DEPTH},"include":${INCLUDE_JSON},"exclude":${EXCLUDE_JSON}},"output":{"formats":${FORMATS_JSON}}}
JSON
)"
fi

curl -sS -X POST "https://run.xcrawl.com/v1/crawl" \
  -H "Authorization: Bearer ${XCRAWL_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
