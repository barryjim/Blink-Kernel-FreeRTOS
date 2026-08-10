#!/usr/bin/env python3
"""find_sdk.py - Locate Silicon Labs SDK asset from GitHub Release assets.

Usage:
    python3 find_sdk.py <github_repository>

Reads the GitHub Releases API, searches for an asset whose name contains
'sdk' or 'simplicity', and prints the download URL on stdout.
Exit code 0 = URL found, 1 = not found.
"""

import sys
import json
import urllib.request
import urllib.error
import ssl


def find_sdk_url(repository: str) -> str:
    api_url = f"https://api.github.com/repos/{repository}/releases?per_page=10"
    ctx = ssl._create_unverified_context()

    req = urllib.request.Request(api_url, headers={
        "Accept": "application/vnd.github+json",
        "User-Agent": "blink_kernel_freertos_s3-ci/1.0",
    })
    try:
        with urllib.request.urlopen(req, context=ctx, timeout=30) as resp:
            releases = json.loads(resp.read().decode("utf-8"))
    except Exception:
        return ""

    for release in releases:
        for asset in release.get("assets", []):
            name = asset.get("name", "").lower()
            if "sdk" in name or "simplicity" in name:
                return asset.get("browser_download_url", "")
    return ""


def main():
    if len(sys.argv) < 2:
        print("Usage: find_sdk.py <github_repository>", file=sys.stderr)
        sys.exit(1)

    repository = sys.argv[1]
    url = find_sdk_url(repository)
    if url:
        print(url)
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()