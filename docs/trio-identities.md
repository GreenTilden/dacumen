# Trio Identities — Naming Your Three Sprints

*The framework runs three parallel sprints. Naming them makes the framework feel less like a diagram and more like a conversation with collaborators. This doc explains the pattern, lists some starter trios, and tells you how to pick your own.*

## Why three, and why name them?

The Foreman^^ framework organizes work into three concurrent sprints that form a learning cascade:

- **Discovery** — runs two or more loops ahead of the others, highest unknowns, generates novel pattern signal
- **Validation** — runs one to two loops behind discovery, stress-tests patterns in a foreign context to prove portability
- **Consolidation** — runs one to two loops behind validation, highest rep count, bakes proven patterns into reflex

Described that way the sprints sound like roles on a spreadsheet. In practice, people run work better when the sprints have personalities. Naming them lets you say *"Dewey found a way around that"* instead of *"the consolidation sprint produced an artifact at L23"* — the first sentence stays in your head, the second one doesn't.

The framework also lets different agents (or different Claude Code sessions) inhabit each sprint. When you and a teammate are both working with DAcumen, you can pass briefs between sprints by identity: *"Louie wrote an upstream brief for Huey before logging off"* is more legible than *"the DTAPE session committed louie-upstream-to-huey.md and then the DDANN session picked it up."*

## The default trio — Huey, Louie, Dewey

DAcumen ships with Donald Duck's nephews as the default identities because three well-known brothers map cleanly onto the three cascade roles, and because the red/green/blue color association is already baked into the example scripts (`sprint-surface.sh` tmux pane colors, `tempo-pane.sh` cascade bars, and the atomic-ledger UI's role accents).

| Identity | Role | Color | Personality hook |
|----------|------|-------|------------------|
| **Huey** | discovery | red (`#f87171`) | Oldest nephew, goes first, leads the cascade. "Huey found something new." |
| **Louie** | validation | emerald (`#50C878`) | Middle nephew, stress-tests what Huey finds, "leads from the middle." Pulls validated patterns back to Huey as upstream briefs and forward to Dewey as downstream briefs. |
| **Dewey** | consolidation | blue (`#58a6ff`) | Youngest nephew, bakes patterns into reflex, highest rep count. "Dewey has the pattern down." |

The order (discovery / validation / consolidation) is what's load-bearing. The specific nephew-to-role mapping is a convention chosen because the red/green/blue sequence matches the order the three roles appear in the cascade display, and because "Louie leads from the middle" is a fun way to describe the validation layer's bidirectional communication role.

### Why the default palette is Huey red, Louie green, Dewey blue

Three reasons:

1. **Distinguishability on a dark background.** Red, emerald, and blue sit at different hue clusters and read cleanly against `#0d1117` without clashing with each other or with the amber/purple accents the framework uses for other semantic roles.
2. **Semantic green for validation.** In most productivity surfaces, green means "tested and passing." Validation is the sprint that tests things. Putting green on validation keeps the default palette semantically honest.
3. **Matches existing conventions.** The atomic-ledger UI, `sprint-surface.sh`, and `tempo-pane.sh` all use red/green/blue for the three sprints independently. Aligning the identity palette with those existing surfaces means one color language everywhere.

You can (and should) recolor during your own onboarding if these defaults don't fit. See **"Pick your own palette"** below.

## Other starter trios

If Donald's nephews don't fit your vibe, here are other trios that map cleanly onto the three roles. Each has an implied discovery/validation/consolidation ordering you can adopt as-is or swap around.

| Trio | Discovery | Validation | Consolidation |
|------|-----------|------------|---------------|
| Three Stooges | Moe (leader) | Larry (middle) | Curly (baker) |
| Chipmunks | Alvin (leader) | Simon (validator) | Theodore (steady) |
| Three Musketeers | Athos (elder) | Porthos (muscle) | Aramis (scholar) |
| Christmas Carol ghosts | Past (finds) | Present (tests) | Future (bakes) |
| Earth/Wind/Fire | Wind (moves) | Fire (tests) | Earth (grounds) |
| Rock/Paper/Scissors | Rock (breaks ground) | Paper (wraps) | Scissors (cuts) |
| Faith/Hope/Love | Hope (reaches) | Faith (holds) | Love (binds) |
| Snap/Crackle/Pop | Snap (starts) | Crackle (tests) | Pop (lands) |
| Id/Ego/Superego | Id (urges) | Ego (mediates) | Superego (patterns) |
| **Write your own** | *your name* | *your name* | *your name* |

There's no wrong answer. The goal is that when you look at your cascade dashboard you see faces, not row numbers.

## Pick your own palette

If you keep the trio names but want different colors (or if you're naming your own trio and need a palette), here's the constraint checklist:

1. **High contrast against a dark background** (`#0d1117`). Test each color at 1rem font size — if it's hard to read, bump saturation.
2. **Three hues at least 60° apart on the color wheel.** Red/green/blue is 120° apart — maximum separation. Red/orange/yellow would be too close.
3. **One of the three should be green-ish for validation.** Green reads as "tested" everywhere. Going against that convention works but costs legibility.
4. **None of them should be amber, purple, or white.** Those are reserved for other semantic roles in the framework (amber = life/domestic, purple = R&D, white = text). Pick hues that don't collide.
5. **Provide a triplet per identity.** Primary, dark (for text-on-color), and pale (for backgrounds). See `ellabot-app/src/styles/tokens.css` for how DAcumen's Louie triplet is structured:

```css
--louie-primary: #50C878;   /* emerald jewel */
--louie-dark: #1f4d3a;      /* deep pine */
--louie-pale: #b3e5c7;      /* mint wash */
```

6. **Test the glass-card version.** The atomic-ledger UI uses the primary hex at ~12% alpha for glass backgrounds and ~45% alpha for glass borders. Make sure your chosen primary looks good at both alphas.

## Wiring it into your config

Once you've picked names and colors, there are three places to edit them:

1. **`~/.claude/CLAUDE.md`** — add a `## Trio Identities` section near the top describing your three sprints and their mapping to discovery/validation/consolidation. This is the source of truth agents read when they need to know which name maps to which role.
2. **`~/.claude/sprints/<name>/charter.md`** — the individual sprint charters reference their identity (e.g., "This is Louie's sprint — the validation layer").
3. **`ellabot-app/src/styles/tokens.css`** (if you run the atomic ledger UI) — update the `--<identity>-primary/-dark/-pale` tokens to your chosen palette. The CascadePanel reads through these variables automatically.

A future DAcumen install.sh loop will prompt for your trio names and palette at setup time and wire all three surfaces for you. Until then the edit is manual — but it's three files, and you only do it once.

## Louie leads from the middle

One last framing note, because it's load-bearing for how the three sprints coordinate.

Each sprint has a natural conversation direction:

- **Huey** (discovery) mostly produces signal for Louie and Dewey to consume.
- **Dewey** (consolidation) mostly receives patterns from Louie and turns them into reusable reflex.
- **Louie** (validation) sits in the middle and talks in both directions — upstream to Huey to refine discovery, and downstream to Dewey to direct what gets baked.

That's why the validation sprint has two canonical cascade-sync artifacts:

- `<sprint>/louie-upstream-to-huey.md` — what Louie validated, what discovery should keep chasing, what should pause
- `<sprint>/louie-downstream-to-dewey.md` — what's ready to bake, what's not, what consolidation should prioritize

These are written in imperative voice so the receiving sprint can execute without re-asking questions. They're the mechanism that makes the cascade self-regulating over time instead of requiring operator intervention every loop.

If you're running DAcumen solo, you can skip the upstream/downstream briefs — just narrate aloud to yourself as Louie. If you're running with teammates or on a schedule with enough gaps that you forget what you were doing, write the briefs. They cost five minutes and save hours of re-context.

## The short version

- Three sprints need names to stay in your head.
- DAcumen defaults to Huey/Louie/Dewey with red/green/blue for distinguishability and semantic-green-for-validation.
- You can swap in any trio (or invent one) as long as the role order (discovery / validation / consolidation) stays.
- Louie's role is bidirectional cascade-sync, and DAcumen provides a two-brief template for how that communication gets written down.
- Your trio is yours. Pick one that makes the framework feel like a conversation with collaborators rather than a diagram.
