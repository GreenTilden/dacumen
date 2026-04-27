# Skeleton — YAML Topic Files Pattern

This skeleton demonstrates the dacumen memory framework's tier-based loading convention applied to a working-memory layout that uses **YAML topic files** for Tier 2 instead of Markdown.

The pattern works equally well with Markdown topic files (which is what `docs/memory-framework.md` documents as the default) — this skeleton just shows the YAML variant for projects that prefer typed data structures for their topic content.

## What's here

- `MEMORY.md` — Tier 1 always-load index (under 200 lines · session status + pointers to topic files)
- `projects.yaml` — Tier 2 topic file: active and queued projects
- `collaborators.yaml` — Tier 2 topic file: working relationships
- `learnings.yaml` — Tier 2 topic file: technical patterns

> All names, projects, decisions, and notes here are illustrative placeholders. Adapt the **shape** to your own data; do not treat the placeholder content as substantive.

## Try it

From the dacumen repo root:

```bash
python scripts/load_by_tier.py skeleton/topic-files-yaml "what's blocking project alpha"
```

The Tier 1 index loads in full. The Tier 2 loader scores `projects.yaml` highest because its `description:` line includes terms like `software projects in flight grouped by status` — overlap with the query terms `project` and `alpha` and `blocking`.

(In production you'd use real semantic similarity instead of word overlap, but the convention is identical — the loader is illustrative.)

## Why YAML for Tier 2

YAML is human-editable, supports frontmatter for metadata, and parses cleanly into typed structures. The convention works equally well with Markdown topic files — the `description:` line in the frontmatter is what the loader scores against.

The choice of format is operator preference. The convention is: **every Tier 2 file has a one-line `description:` in its frontmatter that's good enough to retrieve on.**

## Forking this skeleton

```bash
cp -r skeleton/topic-files-yaml/ ~/your-memory-dir/
# Edit MEMORY.md, replace the placeholder topic files with your own data
```

Then point your AI sessions or your own loader at `~/your-memory-dir/`.
