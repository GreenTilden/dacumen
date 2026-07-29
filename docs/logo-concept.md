# DAcumen — Logo Concept

*The mark is drawn and shipped. This doc is the spec it implements — kept because the reasoning is the useful part, and because anyone forking DAcumen may want to redraw the bird for their own version.*

**Status**

| form | state |
|---|---|
| Favicon (32×32) | **shipped** — `public/favicon.svg`, hand-rolled SVG rectangles on a 32×32 grid |
| Logo (128×128) | **shipped** — `public/logo-128.png` |
| README banner (1200×200) | **shipped** — `public/banner-1200x200.png` |
| Social preview (1200×630) | **shipped** — `public/social-1200x630.png`, not yet uploaded to the repo's social-preview slot |

Every raster form is generated *from* `public/favicon.svg` rather than redrawn, so the SVG stays the single source of truth for the mark. Change the rectangles and the banner follows. Scaling is nearest-neighbour throughout — the mark is defined by where its pixels are, so any smoothing destroys it.

One note on the palette, because it's a lesson rather than a preference: the olive branch's **stem** is ops-blue rather than the shadow dark the rest of the linework uses. Shadow-dark on the dark background is invisible, which nobody notices at 32×32 — but scale the mark to banner size and the leaves float free of the beak, and the bird looks like it's ignoring an unrelated shrub. A color choice that works at one size can be a legibility bug at another.

## The image in words

A **pixelated robot dove** holding an **olive branch** in its beak.

The robot-ness says: this is a toolkit for working with AI. The dove says: this is peaceful, given in friendship, not imposed. The olive branch says: it's an offering. Pixelated because the whole aesthetic of DAcumen is opinionated, retro, and a little playful — not polished-corporate.

The robot dove should look **slightly awkward but earnest**. Not slick. Not Disney-cute. Somewhere between a late-80s sprite and a hand-drawn field guide. If it looks like it could have been on a Bandcamp record sleeve or a small-press zine, that's exactly right.

## Palette suggestions

- **Body / feathers:** off-white (`#e6edf3`) with shadow darks (`#30363d`) — matches the DArnTech dark theme
- **Beak and feet:** warm amber (`#d29922`) — the LIF (life) pillar color
- **Eye:** single pixel of cli-green (`#7ee787`) — the CLI (workshop) pillar color — one point of aliveness
- **Olive branch:** ops-blue leaves (`#58a6ff`), rnd-purple olives (`#a371f7`) — the three colors on the branch pull the three pillars into the icon

That gives the logo a built-in three-pillars reference without having to say it.

## Sizes

Three canonical forms:
- **Favicon** (16×16, 32×32): just the head + beak + one olive
- **README banner** (1200×200 or so): full dove in profile, olive branch prominent, wordmark "DAcumen" set in a heavy slab serif or a monospace block font to the right
- **Social preview** (1200×630): same as README banner but with more background — maybe a subtle pixel grid or starfield behind

## Tone notes

- Not corporate. Don't make it look like a SaaS logo.
- Not ironic. The gift is sincere.
- Not cluttered. One dove, one branch, one wordmark.
- A little weird is fine. It's from a real person.

## Origin-story tie-in (optional)

The name *DAcumen* is a nod to a high-school band of the same name. If the logo wanted to carry a tiny reference, a **pixelated guitar pick in the background** or **a single music-note pixel somewhere** would be a warm easter egg. Entirely skippable — the dove + branch carry the meaning on their own.

## References to look at

- Old Amiga/Atari sprite art for the retro-pixel aesthetic
- Bandcamp record sleeves from small-press labels for the hand-drawn warmth
- Post-it Notes doodles of birds (the dove shouldn't try to look anatomical)
- Any "olive branch" emoji treatment, inverted — the standard olive branch is too polished, DAcumen's version should feel like it was stitched together

## How it got drawn

No commission, no illustrator, no diffusion model. The dove is thirty-odd `<rect>` elements on a 32×32 `viewBox` with `shape-rendering="crispEdges"` — placed by hand, one pixel at a time, in a text editor. That is a slightly ridiculous way to make a logo and it is also exactly the aesthetic the doc above asks for: a late-80s sprite, a little awkward, obviously made by a person.

Two consequences worth knowing if you fork this:

- **The SVG is the source, not an export.** Every raster form comes from it by nearest-neighbour scaling. Nothing is redrawn per size, so nothing can drift between sizes.
- **Editing it is editing text.** Want a different eye color, a fifth leaf, the guitar-pick easter egg? Change a `fill` or add a rect. No design tool required.

The original sketch that preceded it, kept for the record:

```
   .-----.
  / o     \       hand-sketched
 |  ___    |      placeholder
  \_|  \__/_      robot dove
    /    \        with olive
   /  ^   \       branch
  (        )      (you get the idea)
```
