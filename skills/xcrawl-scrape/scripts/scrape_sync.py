#!/usr/bin/env python3
import argparse
import json
import os
import sys

import requests


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Send a sync scrape request to Xcrawl")
    parser.add_argument("url", nargs="?", default=None, help="Target URL (positional shortcut)")
    parser.add_argument("--url", dest="url_opt", help="Target URL")
    parser.add_argument(
        "--formats",
        default="markdown,links",
        help="Comma-separated output formats for shortcut mode (default: markdown,links)",
    )
    parser.add_argument("--payload-file", help="Path to raw JSON payload file")
    parser.add_argument("--payload-json", help="Raw JSON payload string")
    return parser.parse_args()


def load_payload(args: argparse.Namespace) -> dict:
    if args.payload_file and args.payload_json:
        raise SystemExit("Use only one of --payload-file or --payload-json")

    if args.payload_file:
        with open(args.payload_file, "r", encoding="utf-8") as f:
            return json.load(f)

    if args.payload_json:
        return json.loads(args.payload_json)

    url = args.url_opt or args.url or "https://example.com"
    formats = [item.strip() for item in args.formats.split(",") if item.strip()]
    return {
        "url": url,
        "mode": "sync",
        "output": {"formats": formats or ["markdown", "links"]},
    }


def main() -> None:
    api_key = os.getenv("XCRAWL_API_KEY")
    if not api_key:
        raise SystemExit("XCRAWL_API_KEY is required")

    payload = load_payload(parse_args())

    resp = requests.post(
        "https://run.xcrawl.com/v1/scrape",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json=payload,
        timeout=60,
    )
    print(resp.text)
    if not resp.ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
