"""
load_by_tier.py — reference implementation of the dacumen memory framework's
tier-based loading convention. See `docs/memory-framework.md` for the full pattern.

The point of this file is the *convention*, not the code. The convention is:
  Tier 1 = always-loaded index file (MEMORY.md), capped at TIER1_MAX_LINES
  Tier 2 = topic files with frontmatter `description:` lines, scored by query overlap
  Tier 3 = retrieval corpus, searched not loaded (out of scope for this loader)

Fork this. Rewrite it in your language. The convention is what matters; this is
illustrative only — most projects can run the framework without any loader at
all, since Claude Code's auto-memory loads MEMORY.md natively and topic files
get pulled in by relevance via grep or human direction.

Usage:
    python load_by_tier.py /path/to/memory-dir "what is the current sprint state"

Optional dependency: none. Pure standard library.
"""
from __future__ import annotations
from pathlib import Path
import re
import sys

TIER1_INDEX = "MEMORY.md"
TIER1_MAX_LINES = 200


def load_tier1(memory_dir: Path) -> str:
    """Always-load: the MEMORY.md index file, hard-capped to enforce tier discipline."""
    p = memory_dir / TIER1_INDEX
    if not p.exists():
        return f"<no {TIER1_INDEX} found in {memory_dir}>"
    lines = p.read_text(encoding="utf-8").splitlines()
    if len(lines) > TIER1_MAX_LINES:
        truncated = lines[:TIER1_MAX_LINES]
        truncated.append(f"... [truncated at line {TIER1_MAX_LINES} — promote detail to Tier 2 topic files]")
        return "\n".join(truncated)
    return "\n".join(lines)


def _read_description(file_path: Path) -> str:
    """Extract the `description:` line from YAML or Markdown frontmatter."""
    try:
        content = file_path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return ""
    m = re.search(r"^description:\s*(.+)$", content, re.MULTILINE)
    return m.group(1).strip() if m else ""


def load_tier2(memory_dir: Path, query: str, k: int = 5) -> list[tuple[Path, int, str]]:
    """On-demand: score topic files by query-vs-description term overlap, return top-k."""
    if not query:
        return []
    query_terms = [t for t in re.findall(r"\w+", query.lower()) if len(t) > 2]
    candidates: list[tuple[int, Path, str]] = []
    for f in list(memory_dir.glob("*.md")) + list(memory_dir.glob("*.yaml")) + list(memory_dir.glob("*.yml")):
        if f.name == TIER1_INDEX:
            continue
        desc = _read_description(f)
        if not desc:
            continue
        desc_lower = desc.lower()
        # Substring match handles plural/singular without a stemming dependency.
        score = sum(1 for t in query_terms if t in desc_lower)
        if score > 0:
            candidates.append((score, f, desc))
    candidates.sort(reverse=True, key=lambda x: x[0])
    return [(f, score, desc) for score, f, desc in candidates[:k]]


def load_memory(memory_dir: str | Path, query: str = "", k: int = 5) -> dict:
    """Returns {'tier1': str, 'tier2': [(path, score, description), ...]}."""
    d = Path(memory_dir).expanduser().resolve()
    return {
        "tier1": load_tier1(d),
        "tier2": load_tier2(d, query, k),
    }


if __name__ == "__main__":
    memdir = sys.argv[1] if len(sys.argv) > 1 else "."
    q = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else ""
    result = load_memory(memdir, q)
    print(f"=== TIER 1 ({TIER1_INDEX}) ===")
    print(result["tier1"])
    if q:
        print(f"\n=== TIER 2 candidates for query: {q!r} ===")
        for path, score, desc in result["tier2"]:
            print(f"  [{score}] {path.name} — {desc}")
        if not result["tier2"]:
            print("  (no Tier 2 matches — broaden query or check that topic files have `description:` frontmatter)")
