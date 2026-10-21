#!/usr/bin/env python3
"""Report likely visible hardcoded strings; intentionally heuristic.

This is an audit aid, NOT proof that a localization is complete. Human review
must inspect compound/interpolated strings, exports, native UI and accessibility.
"""
from __future__ import annotations

import argparse
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DART = ROOT / "lib"
PATTERNS = [
    re.compile(r"""(?:const\s+)?Text\(\s*(['"])([^'"]{2,100})\1"""),
    re.compile(r"""\b(?:tooltip|labelText|hintText|semanticLabel|helperText|errorText)\s*:\s*(['"])([^'"]{2,100})\1"""),
    re.compile(r"""\b(?:title|body)\s*:\s*(['"])([^'"]{2,100})\1"""),
]


def audit():
    hits = Counter()
    snippets = {}
    for path in sorted(DART.rglob("*.dart")):
        if "generated" in path.parts or path.name.endswith(".g.dart"):
            continue
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.lstrip().startswith(("//", "///", "*")):
                continue
            for pattern in PATTERNS:
                match = pattern.search(line)
                if match is None:
                    continue
                candidate = match.group(2)
                if not any(letter.isalpha() for letter in candidate):
                    continue
                key = path.relative_to(ROOT).as_posix()
                hits[key] += 1
                snippets.setdefault(key, []).append((number, candidate))
                break
    return hits, snippets


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--top", type=int, default=20)
    parser.add_argument("--strict", action="store_true",
                        help="Fail while any potentially untranslated strings remain")
    args = parser.parse_args()
    hits, snippets = audit()
    print(f"Possible untranslated strings: {sum(hits.values())} across {len(hits)} files")
    for path, total in hits.most_common(args.top):
        print(f"{total:4d}  {path}")
        for line, text in snippets[path][:2]:
            print(f"      {line}: {text[:95]}")
    if args.strict and hits:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
