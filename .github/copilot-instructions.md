## Quick orientation

This is a Flutter app named `sade` (app title shown as "Gök Yazı"). Key top-level folders:

- `lib/models/` — data models (many use Hive annotations and have generated `*.g.dart` files).
- `lib/screens/`, `lib/widgets/`, `lib/services/` — UI and service boundaries.
- `assets/` — static JSON, images and fonts (see `pubspec.yaml` for exact asset list).
- `android/`, `ios/`, `windows/`, `web/` — platform folders with platform-specific configs.

Core runtime facts taken from the repo:

- App bootstraps from `lib/main.dart`. Important at start-up:
  - `.env` is loaded via `flutter_dotenv` (see `dotenv.load(fileName: ".env")`). Keep `.env` in project root for local runs.
  - Hive is initialized (`Hive.initFlutter()`), and many adapters are registered (e.g. `KullaniciVerisiAdapter()`, `FalAdapter()`), then the box `appCache` is opened.
  - State uses `provider` (the app wraps `ChangeNotifierProvider` around `KullaniciModel`).

## What an AI coding assistant should know (concrete, code-backed rules)

1. Regenerating model code
   - Models in `lib/models/` use Hive and code-generation. Generated files follow `*.g.dart` naming. When you add or change a `@HiveType` model, run:

     flutter pub run build_runner build --delete-conflicting-outputs

   - `pubspec.yaml` includes `hive_generator` and `build_runner` as dev deps — use them instead of hand-editing `*.g.dart` files.

2. Where to wire new models
   - If you add a Hive model, register its adapter in `lib/main.dart` before opening boxes. Example pattern in repo:

     Hive.registerAdapter(FalAdapter());

   - Open the `appCache` (or create a new box name if needed). Keep naming consistent to avoid fragmentation.

3. Environment values and assets
   - The app expects a `.env` file at project root. Do not remove `.env` loading. New environment keys should be added to `.env` and documented in README or a new `.env.example`.
   - When adding assets (images, JSON), add paths to `flutter.assets` in `pubspec.yaml` (the repo already lists `assets/images/`, `assets/fallar.json`, and `assets/data/*`).

4. Dependency and SDK constraints
   - `pubspec.yaml` sets SDK constraint `>=3.9.0 <4.0.0`. Keep Dart language usage compatible.
   - Common libs to be aware of: `provider`, `hive`, `http`, `flutter_dotenv`, `shared_preferences`, `url_launcher`.

5. Build / run / test commands
   - Fetch deps: `flutter pub get`.
   - Regenerate generated sources: `flutter pub run build_runner build --delete-conflicting-outputs`.
   - Run app locally (choose device): `flutter run` (add `-d windows` or `-d chrome` etc. when needed).
   - Run tests: `flutter test` (project contains `test/widget_test.dart`).

6. Patterns and conventions found in codebase
   - State management: `ChangeNotifier` and `provider` are the default; new cross-screen state should follow this pattern.
   - Data persistence: use Hive boxes and adapters; prefer storing typed objects via registered adapters rather than raw maps.
   - Generated artifacts: many `*.g.dart` files are committed; do not manually edit them — change the source model and regenerate.

7. Debugging notes
   - Early app initialization lives in `main()` — missing adapter registration or failing `.env` keys commonly cause startup crashes.
   - Hive box names (e.g., `appCache`) are hard-coded in `main.dart` — searching for `openBox('appCache')` helps locate persisted data flows.

8. Pull request guidance for AI edits
   - If introducing a new model, include: the model file under `lib/models/`, run `build_runner` to produce `*.g.dart`, add `Hive.registerAdapter(...)` to `lib/main.dart`, and list any new assets in `pubspec.yaml`.
   - Keep changes small and focused: regenerate code in CI or show `build_runner` output in the PR description.

## Key files to inspect when working on features or bugs

- `lib/main.dart` — startup, adapter registration, provider wiring.
- `lib/models/` — domain model definitions and generated `*.g.dart` files.
- `pubspec.yaml` — assets, dependencies, generator config (e.g., `flutter_launcher_icons`).
- `assets/data/` — JSON data consumed by the app (e.g., `mitoloji.json`, `takvim_veritabani.json`, `turk_tarotu.json`).

## If you need to change CI or linting
 - The repo includes `flutter_lints` and `analysis_options.yaml` — follow existing lint rules. Add CI steps to run `flutter pub get`, `flutter test`, and `build_runner` if you add codegen changes.

---
If any part of this is unclear or you'd like me to include example PR checklists or CI job snippets, tell me which area to expand (models, assets, or startup). I can iterate on this file.
