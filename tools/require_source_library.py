#!/usr/bin/env python3
"""Fail clearly when workstation-only source art has not been restored."""

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parent.parent
SOURCE_LIBRARY = ROOT / "assets"


def main() -> int:
    if SOURCE_LIBRARY.is_dir():
        return 0
    print(
        "ERROR: local source-art library is required at "
        f"{SOURCE_LIBRARY}. Restore the approved assets/ artifact before running "
        "npm run validate:source-library or npm run validate:assets.",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
