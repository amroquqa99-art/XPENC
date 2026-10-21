#!/usr/bin/env python3
"""Validate Flutter ARB catalogs without external Python dependencies."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"
TEMPLATE = L10N / "app_en.arb"
PLACEHOLDER = re.compile(r"(?<!\\)\{([a-zA-Z][a-zA-Z_0-9]*)\}")
NAME = re.compile(r"app_([a-z]{2,3}(?:_[A-Za-z0-9]{2,8})?)\.arb$")


def fail(message):
    print(f"ERROR: {message}", file=sys.stderr)


def main():
    try:
        source = json.loads(TEMPLATE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"Cannot load template: {exc}")
        return 1
    keys = {k for k in source if not k.startswith("@")}
    errors = 0
    for path in sorted(L10N.glob("app_*.arb")):
        match = NAME.fullmatch(path.name)
        if not match:
            fail(f"{path.name}: invalid locale filename")
            errors += 1
            continue
        try:
            catalog = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            fail(f"{path.name}: malformed JSON ({exc})")
            errors += 1
            continue
        language = match.group(1)
        if catalog.get("@@locale") != language:
            fail(f"{path.name}: @@locale must equal {language!r}")
            errors += 1
        own = {k for k in catalog if not k.startswith("@")}
        for key in sorted(keys - own):
            fail(f"{path.name}: missing message: {key}")
            errors += 1
        for key in sorted(own - keys):
            fail(f"{path.name}: unknown message: {key}")
            errors += 1
        for key in sorted(keys & own):
            a, b = source[key], catalog[key]
            if not isinstance(b, str):
                fail(f"{path.name}: {key}: message must be a string")
                errors += 1
                continue
            if not isinstance(a, str):
                fail(f"Invalid template message: {key}")
                errors += 1
                continue
            if sorted(PLACEHOLDER.findall(a)) != sorted(PLACEHOLDER.findall(b)):
                fail(f"{path.name}: {key}: placeholder mismatch")
                errors += 1
            source_info = source.get("@" + key, {})
            target_info = catalog.get("@" + key, {})
            expected = set(source_info.get("placeholders", {}))
            observed = set(target_info.get("placeholders", {}))
            if expected != observed:
                fail(f"{path.name}: {key}: metadata placeholder mismatch")
                errors += 1
    if errors:
        print(f"Localization validation failed: {errors} error(s).")
        return 1
    print(f"Localization catalogs OK: {len(keys)} messages.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
