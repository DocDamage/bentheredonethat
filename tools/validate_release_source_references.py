#!/usr/bin/env python3
"""Reject release data that points at local, non-runtime source libraries.

The repository keeps large art libraries beneath ``assets/`` for curator
workstations.  They are deliberately ignored by Git and absent from clean
exports, so a release scene, script, or manifest must only reference admitted
runtime derivatives beneath ``game/``.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


FORBIDDEN_ROOTS = (
    re.compile(r"(?<![a-z0-9_])assets/tilesets(?:/|$)"),
    re.compile(r"(?<![a-z0-9_])assets/expansion(?:/|$)"),
    re.compile(r"(?<![a-z0-9_])assets/characters/sakpix - 8-direction characters - all as of 7-3-26(?:/|$)"),
)
RELEASE_SUFFIXES = {".gd", ".tscn", ".json", ".tres", ".res"}
EXCLUDED_PARTS = {"tests", "validation", "editor"}


def release_files(root: Path) -> list[Path]:
    game = root / "game"
    return sorted(
        path
        for path in game.rglob("*")
        if path.is_file()
        and path.suffix.lower() in RELEASE_SUFFIXES
        and not any(part.casefold() in EXCLUDED_PARTS for part in path.relative_to(game).parts)
    )


def violations(root: Path) -> list[str]:
    problems: list[str] = []
    for path in release_files(root):
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for line_number, line in enumerate(text.splitlines(), start=1):
            normalized = line.replace("\\", "/").casefold()
            if any(forbidden.search(normalized) for forbidden in FORBIDDEN_ROOTS):
                problems.append(f"{path.relative_to(root).as_posix()}:{line_number}: direct local source-library reference")
    return problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args()
    problems = violations(args.root.resolve())
    if problems:
        print("Release source-library validation failed:", file=sys.stderr)
        print("\n".join(problems), file=sys.stderr)
        return 1
    print("Release code contains no direct local source-library references.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
