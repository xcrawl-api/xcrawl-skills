#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  crawl_result.sh --crawl-id ID
  crawl_result.sh ID
USAGE
}

if [[ -z "${XCRAWL_API_KEY:-}" ]]; then
  echo "XCRAWL_API_KEY is required" >&2
  exit 1
fi

CRAWL_ID=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --crawl-id)
      CRAWL_ID="${2:-}"
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

if [[ -z "$CRAWL_ID" && ${#POSITIONAL[@]} -gt 0 ]]; then
  CRAWL_ID="${POSITIONAL[0]}"
fi

if [[ -z "$CRAWL_ID" ]]; then
  usage >&2
  exit 1
fi

curl -sS -X GET "https://run.xcrawl.com/v1/crawl/${CRAWL_ID}" \
  -H "Authorization: Bearer ${XCRAWL_API_KEY}"
