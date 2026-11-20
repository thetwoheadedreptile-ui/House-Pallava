# House-Pallava — Thondaimandalam

A single-player village-estate simulation game set in Thondaimandalam, in the
Varunavanshi Empire. You play **Mayon Pallava** (20), heir of House Pallava — a
fallen royal house, sworn to Province-Lord Vaidhya, living by animal breeding
and the favour of a gullible lord whose wives enforce the tax.

**Engine:** Godot 4.3 (2D). **Everything is free** — Godot is open source,
placeholder art is generated in-repo.

## Run it

1. Install Godot 4.3+ (standard build) — free, ~100 MB, no account needed.
2. Open Godot → **Import** → select this repo's `project.godot`.
3. Press **F5** (Play).

Controls: drag to pan, scroll wheel to zoom.

## Sprint 1 (current)

- Isometric-style 2D village: grass, dirt roads, river, sand bank
- Pallava Seat, huts, granary, kennels, fields, trees — placed on a grid
- 12 walking villagers (farmers, kennelers, woodcutters) who work and haul
  yields to the granary — grain, fodder and wood accumulate live in the HUD
- Drag/zoom camera, HUD resource bar, running Tamil calendar
  (Chithirai…Panguni) with seasons (Ilavenil / Mudhuvenil / Kaar / Kulir)

## Roadmap

- **Sprint 2** — season tick drives the economy: aggregate household
  production/consumption across the five houses (Pallava, Adigaman,
  Suryacholar, Parambu, Kadalon)
- **Sprint 3** — hound breeding sim: Rajapalayam & Kombai lines, genetic
  traits, litters, quality tiers
- **Sprint 4** — sales & exports: 70/30 Vaidhya split, yearly contract, debt
- **Sprint 5** — the 10% first-fruits tithe, the skim, the wives' audit
- **Sprint 6** — the Ledger, Mayon's skill growth, save/load, balancing

## Layout

- `scenes/`, `scripts/` — the game (Godot 4)
- `assets/sprites/` — placeholder pixel art (regenerate with
  `python3 tools/gen_art.py`)
- `docs/DESIGN.md` — design brief for the whole game
