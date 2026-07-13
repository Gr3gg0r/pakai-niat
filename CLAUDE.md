# Agent Guide

Guidance for AI coding agents working in this repo.

## What this is

Pakai Niat — a Flutter app for AI-native capture of tasks, habits, and ideas.
Natural-language input is parsed via OpenRouter; data is stored locally in Isar;
state is managed with Riverpod.

## Layout

- `lib/models/` — Isar collection schemas (entities)
- `lib/services/` — external integrations (OpenRouter) and data access
- `lib/providers/` — Riverpod providers wiring services to UI
- `lib/views/` — screens and widgets
- `test/` — mirrors `lib/` structure

## Commands

```sh
flutter pub get                     # install dependencies
dart run build_runner build -d      # regenerate Isar codegen after schema changes
flutter analyze                     # static analysis — must be clean
flutter test                        # test suite — must pass
flutter run                         # run on a device/emulator
```

## Conventions

- State management: Riverpod providers only — no setState-based architecture,
  no additional state libraries.
- Persistence: Isar collections in `lib/models/`; after editing a schema, run
  build_runner and commit the generated files.
- Never commit secrets. The OpenRouter key lives in `.env` (gitignored,
  bundled as an asset at runtime); `.env.example` documents the shape.
  Tests assume `.env` exists — copy it from `.env.example` if missing.
- Match existing naming and file organization; keep changes minimal.

## Quality gates

Before finishing any change:

1. `dart run build_runner build -d` if you touched an Isar schema.
2. `flutter analyze` — zero warnings/errors.
3. `flutter test` — all green.
4. Update docs (`CLAUDE.md`, `README.md`, `CHANGELOG.md`) if behavior,
   layout, or commands changed.
