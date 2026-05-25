# Gök Yazı — UI Kit

React/JSX recreations of the shipping Flutter app's core screens, as a click-thru prototype.

## Screens
- **SplashScreen** — cosmic bg, glowing app icon, Orkun-runic manuscript line, "Yolculuğa Başla" CTA.
- **OnboardingScreen** — three full-bleed painted slides (Tengri, Yolculuk, Bozkurt).
- **HomeScreen** — 2-col grid of module RuneButtons over the cracked-stone backdrop.
- **FalEkrani** — Irk Bitig divination: question → 3-beat ritual messaging → 3-dice result with Göktürkçe quote + kadim + AI interpretation.
- **TakvimEkrani** — 12-animal Turkic calendar picker.
- **ProfilEkrani** — rank ladder (Yolçı → Bilge → Kam → Tengrici), LevelMeter, trait chips.

## Atoms (`Atoms.jsx`)
`Tamga`, `RuneButton`, `PrimaryButton`, `Dice`, `Card` (variants: default / soft / amber), `LevelMeter`, `Scrim`, `AppBar`.

## Run
Open `index.html`. Navigate via the sidebar or in-screen CTAs. Screen state persists in localStorage.

## Known corners cut
- Tarot, Mythology, and Settings screens are referenced but not wired in this kit (sidebar sends you back to Home). The visual vocabulary for those is covered by the existing atoms + backgrounds.
- Dice-roll interpretations are static sample text, not from a real Irk Bitig lookup.
- Typography substitution: `CinzelDecorative` is loaded from Google Fonts (`Cinzel Decorative`) because the repo's TTF is used only in the standalone font preview. Orkun is loaded from the local TTF.
