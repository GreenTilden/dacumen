# ADR-001 · Carbon-thin as customer-facing surface house standard

**Status**: RATIFIED · 2026-05-02 (cycle-08-huey L12) · memory committed cycle-08-dewey L07 · DAcumen sync queued for operator-confirmed push · **cycle-11 L04 amendments (2026-05-03)**: page-DEEP standard ratified · §11/§12 framework codification · DARK theme default since cycle-9 L02.1

**Pivot ID**: `carbon-thin-house-standard`

## Decision

Carbon design language (tokens · type · 16px grid · hairline borders · naming · a11y conventions) becomes the customer-facing surface house standard for DArnTech.

- **NO Carbon library dependencies** — hand-authored CSS following Carbon conventions + vanilla HTML + light JS.
- **React optional escape hatch** for genuinely complex viz islands within static pages.
- **IBM blue (`#0f62fe`) is primary action color** for customer-facing surfaces.
- **Brand v3 olive (`#747438`) demoted to brand-mark accent only.**
- **Internal ops dashboard** (Vue at `ops.darrenarney.com`) transitionally retains brand v3 palette · multi-cycle migration deferred to cycle-9 autonomous-migration-per-surface arc.

## Context

Cycle-08-huey L11 shipped Sub-D Vue per-deployment Documents at `/review/:deploymentId` per cycle-08-kickoff §4 spec. Operator surfaced preference for static `/customer-hub/misc-hub.html` (Carbon-thin static · prod-only file · operator-WIP) over Vue surface.

Audit revealed:
- Zero Carbon footprint in `src/`
- Two prod-only HTML+CSS files at `/var/www/darntech-ops/customer-hub/` never committed to git
- 30+ Vue files using brand v3 application palette
- Two ratified memories (`project_carbon_mcp_reference_layer.md` + `project_brand_v30_locked.md`) directly conflicted with operator's stated preference

Decision elevated to ground-floor standard with multi-cycle migration implications per operator directive: *"this is the groudn floor we need to do this on if we're going to do it right."*

## Consequences

- **Customer-facing surfaces** (current: `customer-hub/*`; future: deal pages · project hubs · SoW/MOU renders · cross-project surfaces) → Carbon-thin static.
- **Internal ops dashboard** (Vue at `/`, `/ops`, `/review`, `/customers`, `/lorna`, `/charter`) → brand v3 Vue today; multi-cycle migration deferred; cycle-9 autonomous-migration-per-surface arc proposed.
- **Other DArnTech projects** (GBGreg, sprite-forge, beakly, etc.) → Carbon-thin opportunistically when touching new surfaces; full retrofit only if/when justified per project (operator: *"would go back and rebuild gbgreg in this"*).
- **WS-A8 architecture reshape**: Casey backend serves both Carbon-thin static AND Vue dashboard surfaces (no backend rework needed).
- **Sub-D shipped L11** retained for internal-ops dashboard-developer view; customer-facing equivalent migrates to Carbon-thin.
- **Two ratified memories revise · one new memory authors · one rule scope-expands**:
  - `project_carbon_thin_house_standard.md` (NEW · authored cycle-08-dewey L07)
  - `project_carbon_mcp_reference_layer.md` (UPDATED · SUPERSEDED-IN-PART block at top)
  - `project_brand_v30_locked.md` (UPDATED · CLARIFIED block at top · IDENTITY vs APPLICATION split)
  - `feedback_dacumen_sync_dewey_duty.md` (UPDATED · Scope section adds architectural-pivot ADR-shape capture)

## Alternatives considered

| Alternative | Verdict | Reason |
|---|---|---|
| Stay course on Vue brand v3 for everything | REJECTED | Contradicts operator daily-use signal, prevents cross-project portability |
| Carbon library (React or Web Components) | REJECTED | Framework lock-in tax, defeats the portability rationale that motivates the pivot |
| Promote brand v3 olive as primary action with IBM blue accent | REJECTED | Operator's static hub already demotes olive to accent-only per existing carbon.css comment |
| Two-tier permanent (Carbon-thin customer + Vue internal forever) | REJECTED as endpoint, ACCEPTED as transitional posture for cycle-08/09 only | Long-term unification on Carbon-thin per cycle-9 autonomous-migration arc |

## Migration arc (multi-cycle)

- **Cycle-9 first-firing**: MISC customer hub (operator-pick · "small bite of the apple, allows us to apply it to others cleanly")
- **Cycle-10ish**: customer-hub framework/template (so other customers inherit it)
- **Cycle-11ish**: `ops.darrenarney.com` (internal Vue → Carbon-thin)
- **Last**: `darn-tech.com` homepage (after darn3 viz mapped there · operator preserves as canvas)

Cycle-9 = stress-test of work-shape primitive automation discipline · pre-authored single-fire prompts for full H→L→D pass on n=1 surface migration.

## Operator directives (verbatim excerpts)

> *"i like carbon and think the thin version we were building for the dann pages and tried to migrate to aclu shoudl be our new house standard, way cleaner and if we go non-react then we're even better/more portable than vue if i understand but can use react stuff for better viz if we need to. this is the groudn floor we need to do this on if we're going to do it right, i would go back and rebuild gbgreg in this if i did it for grenova for sure"*

> *"perhaps this is a good reference layer to put on dscumen and make usre that we update now and that we switch dacument updates to every-dewey definitely as we need to catch these kinds of architectural pivots and the reasons behind them as well"*

> *"i think i'd prefer misc customer hub personally, small bite of the apple, allows us to apply it to others cleanly, then the hub itself, then the ops dashboard to stay internal. i like darn-tech.com as is now ideally it'll be the last to go after we map of all our current darn3 viz there too"*

## Cross-references

- `project_carbon_thin_house_standard.md` — full pivot spec
- `project_brand_v30_locked.md` — IDENTITY vs APPLICATION clarification
- `project_carbon_mcp_reference_layer.md` — SUPERSEDED-IN-PART block
- `feedback_dacumen_sync_dewey_duty.md` — ADR-shape entry pattern
- `darntech .foreman/cycle.json .pending_dacumen_syncs[].pivot_id="carbon-thin-house-standard"` — full pending-sync entry with sync_targets enumerated
- `darntech docs/foreman/sprints/CHORES-08-HUEY/from-huey-to-dewey-2026-05-02-carbon-thin-pivot.md` — origin handoff doc (369 lines · drafts E/F/G/H + cycle-9 reshape framing)

## Cycle-11 L04 amendments (2026-05-03)

Authored Huey L04 (= cycle-trio L04) as cycle-11 framework-codification work-shape (cycle-11-kickoff §5.4). Five Vue-addendum amendments + memory extensions, all grounded in three audit substrates (`docs/foreman/sprints/CHORES-11-HUEY/audit-{1,2,3}-*-2026-05-03.md`).

### Amendment 1 — §6 page-DEEP standard ratified (reverses cycle-10 punt)

When MIGRATION fires on a parent Vue page, **child components imported in that page's `<script setup>` ARE in-scope by default**. Migration is page-DEEP, not page-shell-only.

**Empirical context**: cycle-10 shipped CharterPage + DarnbotProjectPage shell-level only. The latter visibly carried 2 raw-hex children inside a carbon-thin DARK shell (61 hex occurrences inside `EnclosurePartGallery` + `DarnbotAssemblySteps`). Cycle-11 audit-1 surfaced that **0/53 components consume carbon tokens today** — page-shell-only migration leaves the design system covering ~10% of rendered pixels. Page-DEEP closes the gap.

**Escape clause for theme-prop / theme-state children**: if a child takes color/theme as a prop, maintains theme-state via reactive ref, or renders conditionally based on parent theme-state — escalate at INTERVIEW as separate work-shape OR DEFER with rationale captured as honesty flag. Detection at INTERVIEW grep: `defineProps<{` containing `color` · `theme` · `variant` · `tone`.

**"Embedded in route-registered parent" satisfies §10 pre-flight in modified form** — children are route-indirect · parent's pre-flight inherits via embedding-chain · annotate explicitly in starter prompts ("route-indirect" tag).

**Migration backlog discipline**: 51 components remain after cycle-11 brings the first 2 under coverage. Page-DEEP standard means migration burden propagates with whichever page picks next · cycle-12+ should expect page-DEEP scope at INTERVIEW.

### Amendment 2 — §11 NEW · animations + transitions framework

Codifies how `@keyframes` · `animation:` · `transition:` · `transform:` patterns relate to carbon-thin migration. 8 sections:

1. **Global animation file** target: `src/styles/animations.css` (NOT-yet-created · planned · cycle-12+)
2. **Semantic naming convention**: `purpose-shape` form (e.g. `tab-label-slide-down` not `slideIn`)
3. **Reduced-motion mandatory** (charter-grade · WCAG 2.1 Level AA): every `@keyframes` MUST be guarded · all `infinite` MUST reduce to single-iteration · all `transition` on `transform`/`opacity` MUST respect reduced-motion
4. **Duration discipline**: 80-150ms hover (no guard required) · 150-300ms entrance (guard required) · 1000ms+ highlight (guard required) · `infinite` only for genuine attention-state indicators
5. **`transition: all` is anti-pattern** — always specify properties explicitly
6. **Bare `transform:` outside @keyframes** must respect reduced-motion via media query
7. **Cross-system token references in animations** (e.g. `taskFlash`'s `var(--accent)`) — update atomically at component-migration-time
8. **Brand mark constraint reinforced** — mark MUST NOT rotate · sunburst is STATIC `radial-gradient` · NOT animated · NOT in `src/`

**§8 acceptance-gate addition · gate-9 NEW**: `grep -rn "prefers-reduced-motion" src/styles/` returns at least 1 match (the global guard).

### Amendment 3 — §12 NEW · design one-offs framework

Codifies how off-pattern visual treatments interact with carbon-thin migration. 5 sections:

1. **Gradients**: only brand sunburst (radial · public-facing only) · no gradients in dashboard components · no alpha-via-hex-suffix anti-pattern
2. **Shadows**: hairline-rule preferred · soft-elevation accent allowed (transitional · cycle-9 brand v3.0.1 prior-art) · glow halos / Material-depth / drop-shadow forbidden
3. **Inline SVGs**: `var(--c-*)` at migration-time · `var(--darntech-*)` for brand-mark only · `currentColor` encouraged · chart-palette tier deferred
4. **Custom interactions** (drag-drop · IntersectionObserver · hover-state-machines): NONE in current codebase · scope-decide-at-INTERVIEW IF future component introduces
5. **Token-system fragmentation cleanup discipline (NEW)**: 3 coexisting systems (`--c-*` · `--darntech-*` · `--dt-*` legacy) · 11 `--dt-*` orphan references in 3 brand components · cleanup at component-migration-time NOT swept in isolation

### Amendment 4 — Migration arc updated

Original cycle-08 arc (cycle-9 first-fire MISC · cycle-10ish customer-hub framework · cycle-11ish ops dashboard · last darn-tech.com homepage):
- Cycle-9 ✅ MISC customer hub LIGHT · ratified pre-DARK-correction
- Cycle-10 ✅ shell-level Vue page-migrations on `/charter` + `/projects/darnbot` (DARK)
- Cycle-11 ✅ page-DEEP migration on Darnbot children (DARK · n=4 + n=5 of MIGRATION primitive) + framework codification arc
- **Cycle-12+ projection**: true cold one-shot demonstration on a fresh page (operator picks at cycle-11 close) using the now-ratified §6 + §11 + §12 amendments. Pure-cold cascade evidence still pending (cycle-11 was interrupted-by-design via audit-heavy front-load).

### Amendment 5 — Charter-grade inputs that drove cycle-11 amendments

4 honesty flags surfaced by audits became first-class amendment text inputs:

- **HF-AUDIT-1-3** (HIGH meta · component-wide carbon-thin coverage 0/53 today · 51 remain after cycle-11) → drove §6.5 backlog discipline
- **HF-AUDIT-1-6** (MEDIUM forward · §6 amendment must include theme-prop / theme-state escape clause) → drove §6.3 escape clause
- **HF-AUDIT-2-2** (HIGH a11y · WCAG 2.1 AA · zero `prefers-reduced-motion` guards) → drove §11.3 reduced-motion mandatory + gate-9 NEW
- **HF-AUDIT-3-1** (MEDIUM · 3-token-system fragmentation · 11 legacy `--dt-*` orphan refs) → drove §12.5 cleanup discipline

### Amendment 6 — Reduced-motion accessibility gap is charter-grade

ZERO `prefers-reduced-motion` guards across 53 components + 22 pages is a WCAG-level concern affecting users with vestibular disorders. Cycle-11 ADR amendment elevates this from "future work" to charter-grade compliance gap. Cycle-12+ migrations are gated by reduced-motion compliance once §11 codification ratifies in addendum (this amendment achieves that).

## First-firing notes

FIRST `architectural_pivot`-typed entry in `pending_dacumen_syncs[]`. Existing entries are `amendment_number`-keyed (charter-bundle shape). This entry uses `pivot_id`-keyed shape with ADR fields (decision · context · consequences · alternatives_considered).

Rule expansion (sync_targets `memory_revise_dacumen_sync_dewey_duty`) ratifies this new shape atomically with first ADR-shape sync — empirical first-firing pattern.

Empirical first-firing pattern matches charter-amendment-13j convention: introduce primitive shape and validate it in same cycle that empirically produces it.

## Cycle-12 amendments (2026-05-04 · pre-OPEN substrate)

Authored consolidation-nephew post-close substrate-prep concurrent with charter v0.1.13 ratification (Amendment 14 + Amendment 15). Locks three visual-aesthetic decisions for next cold MIGRATION (substantively-bigger non-Darnbot page).

### Amendment 7 — Glass-card aesthetic dropped (canonical Carbon solid surfaces)

`backdrop-filter: blur(...)` glass-card aesthetic was a brand-v3 transitional pattern. Carbon convention is solid surfaces (`.card { background: var(--c-bg); border: 1px solid var(--c-border); }`). When carbon-thin MIGRATION encounters glass-card patterns:

**Rule**: drop `backdrop-filter` declarations · adopt `.card` global utility (per addendum §3 adoption rule) · solid `--c-surface` background · removes glass aesthetic entirely. Codified at next-cold-MIGRATION substrate §7.2.

### Amendment 8 — Sharp-corner aesthetic (canonical Carbon `border-radius: 0`)

Carbon convention is `border-radius: 0`. Brand-v3 / Tailwind-style 6-12px rounded corners are NOT carbon-thin canonical. When carbon-thin MIGRATION encounters rounded-corner aesthetic:

**Rule**: remove all `border-radius: Npx` declarations · adopt Carbon sharp-corner aesthetic (`.btn { border-radius: 0; }` precedent applies to all surfaces · tag-style elements get `border-radius: 0` matching `.tag` convention). Codified at next-cold-MIGRATION substrate §7.3.

**Honest forward signal**: this is the most-invasive aesthetic shift in any MIGRATION yet. Pages migrating post-Amendment-8 will look meaningfully different — sharp corners + IBM Plex + solid surfaces + IBM blue is the canonical Carbon-docs / IBM-Cloud expression. Mandatory private-tab visual review at MIGRATION-close.

### Amendment 9 — Font-family override forbidden (IBM Plex Sans always)

Pages opting into `class="carbon-surface-dark"` (or `carbon-surface` LIGHT) cascade `font-family: 'IBM Plex Sans', ...` from the wrapper class. Page-scoped `font-family:` overrides break the canonical type-system.

**Rule**: scoped-style does NOT override `font-family` — Carbon-surface wrapper class is the single source of truth. Forward-applies to all post-Amendment-9 migrations. Codified at next-cold-MIGRATION substrate §7.4.

### Amendment 10 — Fallback-chain stripping discipline (LOW · stylistic)

Pages migrating from brand-v3 may consume tokens via fallback chains like `var(--accent, #6366f1)`. After MIGRATION the chain becomes redundant because `carbon.css` is global-imported (`main.ts:4`-shape) so tokens are guaranteed-defined.

**Rule (addendum §4 sub-rule candidate)**: scoped-style consumes use bare `var(--c-X)` · fallback chain is not needed. Stylistic-clarity rule · LOW severity.

### Cycle-12 cascade effects

- Cold-MIGRATION substrate-prep authoring pattern (NEW · empirical first-fire cycle-12) — substrate doc baked operator-locked aesthetic decisions pre-OPEN so single-fire MIGRATION prompt has zero mid-cycle HITL gates
- Visual-shift forward signal becomes a substrate-doc honesty-flag pattern — when pre-MIGRATION aesthetic differs from post-MIGRATION canonical, name the shift in substrate §1 / §8 + require private-tab visual review at MIGRATION-close
- Post-Amendment-8/9/10 migrations look canonically Carbon by default — if a page-pick wants to retain rounded corners / Inter font / glass aesthetic for operator-specific reason, that's an explicit scope-out decision at substrate-prep time NOT a default

### First-firing notes — cycle-12 substrate-prep pattern

NEW empirical pattern: substrate-prepped cold MIGRATION sub-mode (n=1 cycle-12) distinct from cycle-9-style pure-cold sub-mode. Substrate doc captures token-mapping + escape-clause dispositions + operator-locked aesthetic decisions pre-OPEN. This is interview-heavy front-load at page-scale (analogous to cycle-11 audit-heavy front-load at framework-scale). Pure-cold n=2 acquisition (cycle-9 sub-mode) deferred to subsequent cycle on smaller page.

Codification of substrate-prepped cold MIGRATION as a charter-grade pattern deferred until n=2 evidence acquired. Single-fire prompt cascade pattern now sits at n=4 evidence with 4 sub-modes (pure-cold + interrupted-rescued + interrupted-by-design + substrate-prepped).
