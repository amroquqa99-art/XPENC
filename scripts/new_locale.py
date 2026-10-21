#!/usr/bin/env python3
"""Start a new locale: python3 scripts/new_locale.py fr [--force]."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VALID = re.compile(r"[a-z]{2,3}(?:_[A-Za-z0-9]{2,8})?")
if len(sys.argv) not in (2, 3) or not VALID.fullmatch(sys.argv[1]):
    raise SystemExit("Usage: python3 scripts/new_locale.py <locale> [--force]")
if len(sys.argv) == 3 and sys.argv[2] != "--force":
    raise SystemExit("The only optional argument is --force")
code = sys.argv[1]
folder = ROOT / "lib" / "l10n"
out = folder / f"app_{code}.arb"
if out.exists() and "--force" not in sys.argv:
    raise SystemExit(f"Refusing to replace {out}; pass --force if intended.")
template = json.loads((folder / "app_en.arb").read_text(encoding="utf-8"))
template["@@locale"] = code
out.write_text(json.dumps(template, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Created {out.relative_to(ROOT)}")
print("Translate values contextually, preserve placeholders, run scripts/check_l10n.py.")
