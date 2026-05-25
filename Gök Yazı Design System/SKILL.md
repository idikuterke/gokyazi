---
name: gokyazi-design
description: Use this skill to generate well-branded interfaces and assets for Gök Yazı (Gök Labs) — the Old-Turkic divination & mythology mobile app. Contains essential design guidelines, Cosmos/Amber/Cyan color system, Orkun + CinzelDecorative type, painted imagery, tamgas, zodiac animals, and UI-kit React components for prototyping.
user-invocable: true
---

Read the `README.md` file within this skill first — it is the canonical brief covering sources, content fundamentals, visual foundations, and iconography rules.

Then explore the other available files:

- `colors_and_type.css` — CSS variables for the full palette, type scale, spacing, radii, shadows, motion, and semantic tokens. Import at the top of any HTML page.
- `fonts/` — `Orkun.ttf` (Old Turkic runic, runes only) and `CinzelDecorative-Bold.ttf` (display serif, titles/menus).
- `assets/` — logos (`ikon.png`), tamgas (parchment stamps), 12 zodiac animals (`animal_*.png`), painted mythological figures (`bozkurt.png`, `tengri.jpeg`, `ak_ana.png`, `erlik_han.png`, `kam.png`, `dede_korkut.png`, `tomris_hatun.png`), textured backgrounds (`bg_stone.jpeg`, `bg_fal_ekrani.png`, `bg_takvim.jpeg`, `yolculuk.jpeg`), tarot card back, and six menu rune icons (`ikon_*.png`). Copy these — do NOT draw new SVGs.
- `preview/` — small specimen cards that feed the Design System tab (type, color, spacing, components, brand).
- `ui_kits/gokyazi/` — React/JSX click-thru prototype of the mobile app: `SplashScreen`, `OnboardingScreen`, `HomeScreen`, `FalEkrani`, `TakvimEkrani`, `ProfilEkrani`, plus atoms (`RuneButton`, `Tamga`, `Dice`, `Card`, `LevelMeter`, `Scrim`, `AppBar`). Load `index.html` for a working demo.

### Core rules to internalize

- **Every screen has a photographic background** behind a 40–60% black scrim — never flat solid color, never gradient-as-hero, never hand-drawn SVG illustration.
- **Three fonts, non-overlapping jobs:** Orkun for runic glyphs only, CinzelDecorative for titles/menus (ALL CAPS or Title Case + 1.5px tracking), system sans for body.
- **Color:** Cosmos indigo base `#0C0A18` → translucent indigo cards → amber accents (`#FFA000` / `#FFC107`) → cyan glow `rgba(0,255,255,0.6)` for magic / hover.
- **Voice:** Turkish, informal *sen*, evocative and reverent — fortune-teller meets museum docent. Loading text is ritual, never mechanical. No emoji in UI (only in share-sheet text).
- **Motion:** 200 ms hover, 300 ms page change, 500 ms ritual text, 600 ms tarot flip. Default Material easing. No bounces, no overshoots.

### If the user invokes this skill without guidance

Ask what they want to build or design (screen? asset? prototype? slide?), ask a few targeted questions about audience and scope, then act as an expert designer. Output static HTML artifacts for one-off visuals or mocks; adapt the JSX atoms for production work. Always copy real assets out of `assets/` rather than inventing.
