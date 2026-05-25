# Gök Yazı — Design System

> *"Göklere uzanan bir yolculuk."* — A journey that reaches the heavens.

**Gök Yazı** (*"Sky Writing"*) is a mobile divination and mythology app by **Gök Labs** that brings ancient Turkic wisdom into a pocket-sized experience. Users ask a question, roll symbolic dice, and receive readings from the *Irk Bitig* — an 8th–10th century Old Turkic divination manuscript — alongside a Turkic-themed tarot, a 12-animal zodiac calendar, a mythology dictionary, and a personal profile that tracks their progress from **Yolçı** (*Traveler*) → **Bilge** (*Sage*) → **Kam** (*Shaman*) → **Tengrici** (*Sky-worshipper*).

The brand leans hard into **kadim** (*ancient*) — pre-Islamic Turkic cosmology, the sky-father **Tengri**, the grey wolf **Börü/Bozkurt**, the twelve-animal calendar, runiform Orkhon script, and the aesthetic of weathered stone, parchment, and starlit indigo skies.

---

## Sources

The entire visual and content language here was reverse-engineered from the Flutter codebase of the shipping app:

- **Primary codebase:** `idikuterke/gokyazi` (Flutter, main branch) — screens in `lib/screens/`, widgets in `lib/widgets/`, models in `lib/models/`, imagery in `assets/images/`, fonts in `assets/fonts/`.
- **App entry point:** `lib/main.dart` — declares `scaffoldBackgroundColor: Color(0xFF0C0A18)`, dark `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`, and `fontFamily: 'Orkun'`.
- **Attached repo caveat:** The user originally attached `idikuterke/rehber-copilot`, which contains only a one-line README. Because Gök Labs is the stated company and `idikuterke/gokyazi` is the only non-empty product under the same owner, this design system was built from `gokyazi`. If `rehber-copilot` is a different product and source becomes available, it will need its own pass.

No Figma file was provided.

---

## Index

- **`README.md`** — this file. Brand overview, content fundamentals, visual foundations, iconography.
- **`colors_and_type.css`** — CSS variables for the full color palette, typography scale, spacing, radii, shadows, and semantic tokens (`--h1`, `--body`, `--bg-cosmos`, `--accent-amber`, etc.). Import once at the top of any page.
- **`fonts/`** — `Orkun.ttf` (Old Turkic runic), `CinzelDecorative-Bold.ttf` (display serif, used for titles and button labels).
- **`assets/`** — logo (`ikon.png`), tamga glyphs (stamp-like parchment icons), 12 zodiac animal illustrations (`animal_*.png`), mythological figures (`bozkurt.png`, `tengri.jpeg`, `kam.png`, `ak_ana.png`, `erlik_han.png`, …), textured backgrounds (`bg_stone.jpeg`, `bg_fal_ekrani.png`, `bg_takvim.jpeg`, `yolculuk.jpeg`), tarot card back (`tarot_arkayuz.png`), and menu icons (`ikon_*.png`).
- **`preview/`** — Design-system preview cards surfaced in the Design System tab (typography specimens, swatches, component states, etc.).
- **`ui_kits/gokyazi/`** — React/JSX recreations of the mobile app: `SplashScreen.jsx`, `OnboardingScreen.jsx`, `HomeScreen.jsx`, `FalEkrani.jsx` (Irk Bitig divination), `TarotEkrani.jsx`, `ProfilEkrani.jsx`, plus atoms (`RuneButton`, `Tamga`, `Dice`, `Card`, `LevelMeter`). Launch via `ui_kits/gokyazi/index.html`.
- **`SKILL.md`** — portable skill manifest so this bundle can be dropped into Claude Code.

---

## Content fundamentals

The app speaks **Turkish**, second-person informal (*sen*), in a tone that is **evocative, mystical, reverent** — part fortune teller, part museum docent. It treats the user as a seeker on a journey, not a consumer.

### Voice

- **Informal "sen"** everywhere. *"Niyetine ve soruna odaklan..."* ("Focus on your intention and your question…"), never *"Niyetinize odaklanınız"* (formal).
- **Imperatives soften into invitations.** *"Yolculuğa Başla"* ("Begin the journey"), *"Kartları Çek"* ("Draw the cards"), *"Zarları At"* ("Cast the dice"). Direct but poetic.
- **Second-person narrative in onboarding.** *"Bilgelik kazandıkça Bilge, Kam ve nihayetinde Tengrici olacaksın."* ("As you gain wisdom you will become a Sage, a Kam, and finally a Tengri-worshipper.")
- **First-person in shared cards only**, where the user is proud. *"12 Hayvanlı Türk Takvimi'ne göre benim yıl hayvanım: At!"*
- **Loading and ritual copy is mysterious, never mechanical.** The three dice-casting messages in `fal_ekrani.dart` read:
  - *"Niyetine ve soruna odaklan..."*
  - *"Ata ruhları seni dinliyor..."*
  - *"Irk Bitig yol gösterecek..."*
  Never "Loading…", never a spinner alone.

### Casing

- **Menu labels are ALL CAPS** in `CinzelDecorative` with wide tracking: `IRK BİTİG`, `TÜRK TAROTU`, `TAKVİM`, `MİTOLOJİ`, `PROFİL`, `AYARLAR`.
- **Screen titles and buttons are Title Case Turkish** in the default font: *"Yolculuğa Başla"*, *"Yıllık Yorumu Al"*, *"Yeni Soru Sor"*.
- **Body copy is sentence case.**

### Domain vocabulary (use these exact words)

| Turkic word | Meaning | Where it shows up |
|---|---|---|
| **Tengri** | Sky-god, supreme deity | Onboarding, mythology screen |
| **Kut** | Sacred energy, fortune | Level-up descriptions |
| **Ülgen** | Creator-spirit of the upper world | Mythology, rank titles |
| **Börü / Bozkurt** | Wolf / grey wolf, guiding spirit | Onboarding, mythology |
| **Bars** | Panther, one of twelve zodiac | Calendar |
| **Irk Bitig** | 9th-c. divination manuscript | Primary fortune screen |
| **Yolçı → Bilge → Kam → Tengrici** | Rank progression | Profile |
| **Kader Puanı** | "Destiny Points" | Profile stat |
| **Müçel** | 12-year cycle of life | Calendar reading |
| **Tamga** | Tribal stamp/seal glyph | Icons throughout |
| **Göktürkçe** | Old Turkic / Orkhon script | Shown in `Orkun` font |

### Emoji

Sparingly, and only in **user-shared text** (share sheets) where it reads as warm and personal — e.g. `🐎` next to a shared zodiac animal, `✨` for "the sky is interpreting your question". **Never inside the app UI itself.** No emoji on buttons, headers, menus, or tiles.

### Examples pulled from code

- Share sheet (Irk Bitig): *"Gök Yazı uygulamasıyla sorduğum soruya gelen yanıt: Sorum: '…' Yorum: '…' Sen de kadim Türk bilgeliğiyle yolunu aydınlatmak için Gök Yazı'yı indir!"*
- Error recovery (never alarming): *"Yorum alınırken bir sorun oluştu. Lütfen internet bağlantınızı kontrol edin."*
- Empty state: *"Geçmiş fal bulunmuyor."* (simple, italic, 70% white).

---

## Visual foundations

### Color

The world is **deep night indigo** washed with starlight, punctuated by **amber/gold** for value and **neon cyan** for magic. Never candy-bright, never pastel.

- **Base canvas:** `#0C0A18` (cosmos) — the `scaffoldBackgroundColor` declared in `main.dart`. All screens sit on this.
- **Deep purple seed:** `Colors.deepPurple` via `ColorScheme.fromSeed` — generates the surface hierarchy.
- **Card surface:** `rgba(20, 18, 38, 0.8)` — a slightly lifted indigo over the cosmos. Used for profile cards, dialog backgrounds.
- **Scrim / overlays:** `rgba(0, 0, 0, 0.5)` on top of textured backgrounds to push imagery back; `rgba(0, 0, 0, 0.2)` for subtle press wells.
- **Amber accent:** `Colors.amber[700]` ≈ `#FFA000` for primary buttons; `Colors.amber` ≈ `#FFC107` for headlines/headings; `Colors.amber.shade200` ≈ `#FFE082` for inline section labels.
- **Cyan magic:** `rgba(0, 255, 255, 0.6)` as a `BoxShadow` on hover — the "rune is charged" glow.
- **Text hierarchy:** `#FFFFFF` primary, `rgba(255,255,255,0.7)` secondary, `rgba(255,255,255,0.5)` tertiary, `rgba(255,255,255,0.24)` disabled/divider.
- **Danger:** `Colors.red` — only in destructive dialog actions ("Sil").
- **Success:** `Colors.green` — only in confirmation snackbars.
- **Special-info blue:** `Colors.cyan.shade300` ≈ `#4DD0E1` — marks the Gemini-AI-generated interpretation labels in the profile so they're distinguishable from the amber static labels.

The exact tokens live in `colors_and_type.css`.

### Typography

Three families, each with a non-overlapping job.

- **Orkun** (`fonts/Orkun.ttf`) — Old Turkic runic script. Only used to render actual Göktürkçe text (the manuscript quote on splash, the dice-combination key in the history list, the "Kadim Metin" detail view). Sized generously: 22–26 px. Never for Latin characters.
- **CinzelDecorative-Bold** (`fonts/CinzelDecorative-Bold.ttf`) — decorative Roman serif with flared caps. Used for menu labels, screen titles, rank titles ("Yolçı", "Kam"), and section headers. Always uppercase or Title Case, letter-spacing `1.5`. 16–20 px in the app.
- **System default** (Flutter's default: Roboto on Android, SF Pro on iOS) — body, paragraphs, button labels, form inputs. 14–18 px.

There is no tabular/mono font in the system; numeric stats use the system font at bold weight.

### Spacing & layout

- **4 px base grid.** Observed increments: 4, 8, 12, 16, 20, 24, 30, 40.
- **Screen padding:** 16 px default, 24 px for hero/empty states, 32 px for centered input columns.
- **Card padding:** 16–20 px.
- **Grid (home):** 2 columns portrait, 3 landscape. `crossAxisSpacing: 20`, `mainAxisSpacing: 20`, `childAspectRatio: 1.2`.
- **`extendBodyBehindAppBar: true`** is set on nearly every screen — the top bar is transparent and the hero imagery bleeds behind it. This is a signature: the full-bleed textured background is almost never clipped.

### Backgrounds

**Every screen has a photographic background.** This is the most distinctive rule in the system.

- Splash: `acilis_ekrani_bg.png` (hand-painted cosmos)
- Home: `scrool_buton.jpeg` (cracked stone slab)
- Irk Bitig: `fal_ekrani_bg2.png`
- Tarot: stone slab reused with a `BlendMode.darken` overlay at 50% black
- Mythology / Settings: `genel_arkaplan.png` / `turk_tarot.png`
- Zodiac picker: `takvim_arkaplan.png` — with an **animated 12-animal wheel** rotating once per 150 s on top
- Onboarding: per-slide full-bleed (`tengri.jpeg`, `yolculuk.jpeg`, `bozkurt.png`)

There are **no flat solid backgrounds**, no gradients-as-hero, no illustrations drawn inline. Everything is art + scrim.

### Borders, corners, shadows

- **Corner radius:** 8 px (small — image thumbs), 12 px (cards, dialog, form fields), 15 px (home tiles, profile cards), 25 px (pill buttons).
- **Borders:** 1 px, usually `rgba(255,255,255,0.1)` on tiles, `Colors.amber.withOpacity(0.5)` on mythology-entry cards (the amber hairline is a callout motif), `rgba(255,255,255,0.2)` on detail cards.
- **Shadows:** no elevation shadows on cards — surfaces are differentiated by translucent black, not drop shadow. **Hover / press adds a cyan outer glow** only: `BoxShadow(color: rgba(0, 255, 255, 0.6), blurRadius: 25, spreadRadius: 3)`. On resting state the shadow list is empty `[]`.
- **Text shadow** is common on body text that sits over imagery: `Shadow(blurRadius: 10, color: Colors.black)` or `blurRadius: 5`. Use it whenever white text lands on photography.

### Animation

- **Quick hover/press:** `AnimatedContainer(duration: 200ms)` — the rune-button uses this to fade the cyan glow in and out.
- **Page change (onboarding):** `AnimatedSwitcher(duration: 300ms)` with default crossfade.
- **Ritual messaging (dice cast):** three sequential `Future.delayed(2s)` beats, each with a `AnimatedOpacity(duration: 500ms)` for the text. Total ritual lasts ~7 s.
- **Tarot flip:** custom 600 ms 3D Y-axis rotation (`Matrix4.rotationY`).
- **Zodiac wheel:** 150 s full rotation, endlessly repeating.

Easing is **default `Curves.easeIn` / `easeOut`**. No springy bounces, no elastic overshoots — the app feels meditative, not playful.

### Hover, press, disabled states

- **Hover / tap down** on a home tile: cyan glow appears (`boxShadow`); on tap up it disappears and navigation fires. There is no scale-down, no color shift.
- **Disabled primary button:** `backgroundColor: Colors.black.withAlpha(80)` (half the active opacity) and `onPressed: null`.
- **Disabled = greyed via alpha, not a new color.**
- **Focused text input:** border shifts from `rgba(255,255,255,0.5)` white at 50% → solid `Colors.amber` on focus. Unfocused placeholder sits at 70% white.

### Transparency & blur

Transparency carries the whole interface. **Blur is not used** — there are no backdrop-filter effects. Cards and scrims are solid translucent black or solid translucent indigo.

Layering rules:
1. Photographic background (BoxFit.cover).
2. Optional darken scrim (`BlendMode.darken`, `rgba(0,0,0,0.5)`) or plain black at 50–80%.
3. Translucent indigo/black card (`rgba(20,18,38,0.8)` or `rgba(0,0,0,0.5)`) with a 1 px light border.
4. Content — white text, amber headlines, image thumbs, chips.

### Imagery tone

All commissioned art is **warm-leaning, painterly, slightly weathered**. Three buckets:

- **Parchment tamgas** — sepia, ornate Turkic scroll borders, single central figure in rough black ink. Used as module icons on the home grid when zoomed in; also as standalone emblems.
- **Tattoo-style animals** — black ink silhouettes filled with dense Turkic knotwork. Used for the 12-animal zodiac and rotating wheel.
- **Painted myth portraits** — rich oil-painting style of Tengri, Bozkurt, Ak Ana, Erlik Han. Warm browns, deep blues, candlelit. Hung in the mythology screen like icons in a cathedral.

Backgrounds skew **cool and cosmic**; figures skew **warm and hand-made**. The tension between them is the brand.

### Layout rules

- Hero content is **vertically centered** on nearly every utility screen (splash, dice-cast prompt, onboarding, tarot layout picker).
- Lists use `ListView` with `padding: EdgeInsets.all(16)` and a 16 px bottom margin between cards.
- AppBar is always transparent, `elevation: 0`, `centerTitle: true` where a title exists.
- Bottom-aligned primary action button, 50 px min height, full width within a 24 px padded column.

---

## Iconography

### System-level icons: Material Icons (built-in)

The app leans on Flutter's built-in Material icon set for UI chrome:

- `Icons.arrow_back` — back nav
- `Icons.share` — share sheet
- `Icons.person_outline` — profile
- `Icons.calendar_today` — date picker
- `Icons.auto_awesome` — AI-interpretation CTA
- `Icons.email_outlined`, `Icons.delete_sweep_outlined`, `Icons.info_outline` — settings
- `Icons.public_outlined`, `Icons.explore_outlined`, `Icons.color_lens_outlined`, `Icons.circle_outlined` — zodiac cosmology rows
- `Icons.filter_vintage_outlined` — tarot list leading
- `Icons.image_not_supported`, `Icons.broken_image` — image error fallback

In HTML recreations we substitute **[Lucide](https://lucide.dev)** via CDN — same outlined, 2 px stroke aesthetic. Flagged substitutions: `auto-awesome` → `sparkles`, `filter_vintage_outlined` → `flower`, `delete_sweep_outlined` → `trash-2`.

### Brand-level icons: PNG tamgas and menu runes

The *distinctive* icons are **raster PNGs**, not SVG, not icon fonts:

- `assets/ikon_irk_bitig.png`, `assets/ikon_tarot.png`, `assets/ikon_takvim.png`, `assets/ikon_mitoloji.png`, `assets/ikon_profil.png`, `assets/ikon_ayarlar.png` — the six home-grid module icons. Each is a stone disk with a neon-cyan-glowing rune or glyph relevant to the module (dice spread for Irk Bitig, wheel for calendar, etc.).
- `assets/tamga_fal.png`, `assets/tamga_tarot.png`, `assets/tamga_takvim.png`, `assets/tamga_mitoloji.png`, `assets/tamga_profil.png` — parchment-style tamgas (tribal stamps) used as alt branding marks.
- `assets/ikon.png` — the app launcher icon. Stone disk with two neon-blue runes ("Ɗ Ⱨ"-like glyphs) glowing cyan.

**Rule:** module icons are rendered at 60 px height in the grid (see `home_screen.dart`: `Image.asset(..., height: 60)`). Tamgas are rendered full-bleed within a square tile.

### Usage of text as icons

Yes. The Old Turkic runic glyph strings in the Orkun font are used *as* decorative iconography on the splash screen and in the history list (where each saved reading is keyed by a 3-digit dice roll shown as "𐰋𐰋𐰋" etc.). This is unusual and distinctive — treat the runes as a first-class typographic icon asset, not just text.

### Emoji

Only in share-sheet text (`🐎` for horse year, `✨` for AI reading). **Never in-app.**

### SVG

The codebase ships zero custom SVG. All illustration is raster. This is intentional — everything is hand-painted look. **Do not draw new SVG icons in-brand**; if you need a symbol we don't have, either use a Lucide icon (and flag it) or request a raster asset.

---

## Font substitutions flagged

Both brand fonts were imported from the repo:
- ✅ `Orkun.ttf` — imported (actual Old Turkic runic)
- ✅ `CinzelDecorative-Bold.ttf` — imported

If either fails to render (e.g. browser blocks local fonts), fallback should be:
- Orkun → no good web fallback. Accept that Old Turkic text will not render and show transliteration instead.
- CinzelDecorative → [Cinzel Decorative](https://fonts.google.com/specimen/Cinzel+Decorative) from Google Fonts (Bold weight) — near-identical open source release. 🚩 Substitution flagged.

System/body font → stack of `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif` to match Flutter's platform default.

---

## ⚠️ Caveats

1. **Wrong repo attached?** The prompt attached `idikuterke/rehber-copilot`, which is empty (only `README.md: "Rehber Co-Pilot - AI Supported EdTech App"`). This system was built from `idikuterke/gokyazi` because it is the only non-empty product under the same author and matches the "Gök Labs" brand. **If Rehber Co-Pilot is a separate EdTech product, a full second pass is needed** — please reattach with real source.
2. **No Figma.** Component spacing and sizing were inferred from Dart code. A real Figma file would tighten numbers.
3. **Imagery is AI-painted in the source repo.** We preserved it verbatim. If the team is migrating to commissioned art, the painting style above is the north star.
