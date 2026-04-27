# Independent Operator Working Memory — Skeleton

> **Skeleton example.** All project, person, and decision references below are illustrative placeholders. Adapt the shape to your own data; the placeholder content is not substantive.

## Session Status
- **Status**: active
- **Current Focus**: refactoring the embedding pipeline for project-alpha
- **Blockers**: waiting on stakeholder decision about retention policy
- **Next Steps**: ship retrieval API draft, then circle back to stakeholder
- **Last Updated**: 2026-04-27

## Project Identity
- **Purpose**: Working memory for an independent operator running multiple concurrent projects, demonstrating tier-based loading with YAML topic files
- **Stack**: YAML topic files + Tier-1 index (this file) + minimal Python loader (`scripts/load_by_tier.py`)

## Topic files (Tier 2 — on-demand)

- [Active projects](projects.yaml) — concurrent projects by status
- [Collaborators](collaborators.yaml) — people I work with across projects
- [Learnings](learnings.yaml) — patterns and discoveries worth remembering

## Decisions

- **2026-04-15**: Standardized on tier-based memory loading instead of dumping everything into context.
- **2026-04-22**: Adopted the dacumen memory framework so collaborators on any project inherit the same convention without licensing friction.
