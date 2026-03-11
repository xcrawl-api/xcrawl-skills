#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scrape_async_result.sh --scrape-id ID
  scrape_async_result.sh ID
USAGE
}

if [[ -z "${XCRAWL_API_KEY:-}" ]]; then
  echo "XCRAWL_API_KEY is required" >&2
  exit 1
fi

SCRAPE_ID=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scrape-id)
      SCRAPE_ID="${2:-}"
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

if [[ -z "$SCRAPE_ID" && ${#POSITIONAL[@]} -gt 0 ]]; then
  SCRAPE_ID="${POSITIONAL[0]}"
fi

if [[ -z "$SCRAPE_ID" ]]; then
  usage >&2
  exit 1
fi

curl -sS -X GET "https://run.xcrawl.com/v1/scrape/${SCRAPE_ID}" \
  -H "Authorization: Bearer ${XCRAWL_API_KEY}"
