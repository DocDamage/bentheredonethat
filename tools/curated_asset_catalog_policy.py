"""Shared curated-source admission policy for catalog tooling."""

from __future__ import annotations

from pathlib import PurePosixPath


# Assets restored beneath these roots are unreviewed local staging libraries,
# not part of the approved curated source library.  Both catalog generation and
# validation must apply this same policy so the catalog denominator is stable.
QUARANTINED_SOURCE_PREFIXES = frozenset({
    ("assets", "expansion"),
    ("assets", "characters", "recruitable characters", "abe_lincoln"),
    ("assets", "characters", "recruitable characters", "cthulhu"),
    ("assets", "characters", "recruitable characters", "dark_mage_64x64_pack"),
    ("assets", "characters", "recruitable characters", "draculafinal"),
    ("assets", "characters", "recruitable characters", "frankenstein_s_monster"),
    ("assets", "characters", "recruitable characters", "gandhi_sprite"),
    ("assets", "characters", "recruitable characters", "fighter", "animations"),
    ("assets", "characters", "recruitable characters", "fighter", "rotations"),
})


def is_quarantined_source_path(value: str | PurePosixPath) -> bool:
    """Return whether a repository-relative path belongs to an unreviewed tree."""
    parts = tuple(part.casefold() for part in PurePosixPath(value).parts)
    return any(parts[:len(prefix)] == prefix for prefix in QUARANTINED_SOURCE_PREFIXES)
