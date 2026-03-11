#!/usr/bin/env python3
import argparse
import json
import os
import sys
import time

import requests


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create and poll an Xcrawl crawl task")
    parser.add_argument("url", nargs="?", default=None, help="Entry URL (positional shortcut)")
    parser.add_argument("--url", dest="url_opt", help="Entry URL")
    parser.add_argument("--limit", type=int, default=100, help="Crawler limit for shortcut mode")
    parser.add_argument("--max-depth", type=int, default=2, help="Crawler max_depth for shortcut mode")
    parser.add_argument(
        "--formats",
        default="markdown",
        help="Comma-separated output formats for shortcut mode",
    )
    parser.add_argument("--payload-file", help="Path to raw JSON payload file")
    parser.add_argument("--payload-json", help="Raw JSON payload string")
    parser.add_argument("--interval", type=float, default=2.0, help="Polling interval in seconds")
    parser.add_argument("--max-attempts", type=int, default=30, help="Polling max attempts")
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
        "crawler": {
            "limit": args.limit,
            "max_depth": args.max_depth,
        },
        "output": {
            "formats": formats or ["markdown"],
        },
    }


def main() -> None:
    api_key = os.getenv("XCRAWL_API_KEY")
    if not api_key:
        raise SystemExit("XCRAWL_API_KEY is required")

    args = parse_args()
    payload = load_payload(args)
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    create_resp = requests.post(
        "https://run.xcrawl.com/v1/crawl",
        headers=headers,
        json=payload,
        timeout=60,
    )
    create_text = create_resp.text
    print(create_text)
    if not create_resp.ok:
        sys.exit(1)

    try:
        create_data = create_resp.json()
    except ValueError as exc:
        raise SystemExit(f"create response is not JSON: {exc}")

    crawl_id = create_data.get("crawl_id")
    if not crawl_id:
        raise SystemExit("crawl_id missing in create response")

    for attempt in range(args.max_attempts):
        result_resp = requests.get(
            f"https://run.xcrawl.com/v1/crawl/{crawl_id}",
            headers={"Authorization": f"Bearer {api_key}"},
            timeout=60,
        )
        result_text = result_resp.text
        if not result_resp.ok:
            print(result_text)
            sys.exit(1)

        try:
            result_data = result_resp.json()
        except ValueError as exc:
            raise SystemExit(f"result response is not JSON: {exc}")

        status = result_data.get("status")
        if status in {"completed", "failed"}:
            print(result_text)
            return

        if attempt < args.max_attempts - 1:
            time.sleep(args.interval)

    raise SystemExit(
        f"polling timed out after {args.max_attempts} attempts; crawl_id={crawl_id}"
    )


if __name__ == "__main__":
    main()
