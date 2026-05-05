#!/usr/bin/env python3

from __future__ import annotations

import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXTERNALS = ROOT / "home" / ".chezmoiexternal.toml.tmpl"

block_re = re.compile(r'^\["(?P<dest>[^"]+)"\]$')
url_re = re.compile(
    r'^\s*url\s*=\s*"https://github\.com/(?P<owner>[^/]+)/(?P<repo>[^/]+)/archive/refs/tags/(?P<tag>[^"]+)\.tar\.gz"\s*$'
)


def latest_tag(owner: str, repo: str) -> str:
    cmd = (
        f"git ls-remote --tags --refs https://github.com/{owner}/{repo}.git "
        f"| awk '{{print $2}}' "
        "| sed 's#refs/tags/##' "
        "| grep -E '^(v)?[0-9]+(\\.[0-9]+)*$' "
        "| sort -V "
        "| tail -n 1"
    )
    out = subprocess.check_output(["bash", "-lc", cmd], text=True).strip()
    if not out:
        raise RuntimeError(f"no tags found for {owner}/{repo}")
    return out


def main() -> int:
    current_dest = None
    entries: list[tuple[str, str, str, str]] = []

    for line in EXTERNALS.read_text().splitlines():
        m = block_re.match(line)
        if m:
            current_dest = m.group("dest")
            continue
        m = url_re.match(line)
        if m and current_dest:
            entries.append((current_dest, m.group("owner"), m.group("repo"), m.group("tag")))

    if not entries:
        print(f"No pinned GitHub archive URLs found in {EXTERNALS}", file=sys.stderr)
        return 2

    updates = 0
    for dest, owner, repo, current in entries:
        try:
            latest = latest_tag(owner, repo)
        except Exception as exc:
            print(f"{dest}: error fetching tags for {owner}/{repo}: {exc}", file=sys.stderr)
            updates += 1
            continue

        status = "up to date" if current == latest else "update available"
        print(f"{dest}: {status} (current {current}, latest {latest})")
        if current != latest:
            updates += 1

    return 1 if updates else 0


if __name__ == "__main__":
    raise SystemExit(main())
