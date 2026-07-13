# Contributing to Pakai Niat

Thanks for your interest. Pakai Niat is a solo-maintained project — PRs and
issues are welcome, but response times vary. Small, focused changes are the
easiest to review.

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (stable channel).
2. Fork and clone the repo.
3. Install dependencies:

   ```sh
   flutter pub get
   ```

4. Copy `.env.example` to `.env` and add an OpenRouter API key — a free key
   from the [OpenRouter keys page](https://openrouter.ai/keys) is enough. The
   app routes through free models, which have daily request limits; if you hit
   one, wait for the reset or add credit to the key.

   ```sh
   cp .env.example .env
   # then edit .env and set OPENROUTER_KEY=...
   ```

   `.env` is gitignored — never commit it.

5. Run Isar code generation (regenerates `lib/models/*.g.dart`; safe to
   re-run whenever collection schemas change):

   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```

6. Run the tests:

   ```sh
   flutter test
   ```

7. Launch the app:

   ```sh
   flutter run
   ```

   Pick a connected device or emulator when prompted.

For iOS **device** deploys you need your own Apple development team: open
`ios/Runner.xcworkspace` in Xcode and set **Signing & Capabilities → Team**.
The repo ships with `DEVELOPMENT_TEAM` empty — don't commit your team ID.

## Local files that must never be committed

These hold secrets or machine-specific signing material and are all
gitignored — keep them that way:

- `.env` — your OpenRouter API key
- `android/key.properties` — release signing config (keystore path + passwords)
- `*.keystore`, `*.jks` — Android signing keystores

CI fails any push that tracks one of these files. If you ever commit a
secret by accident, rotate it first, then scrub it from history.

## Quality gates

Before opening a PR, both of these must pass locally:

```sh
flutter analyze
flutter test
```

If you changed anything user-visible, add or update tests where it makes sense.

## Code style

- Follow `analysis_options.yaml` (based on `flutter_lints`). The analyzer is
  the authority — no warnings left behind.
- State management via Riverpod; persistence via Isar. Match the existing
  structure in `lib/` rather than introducing new patterns.
- No secrets, API keys, or endpoints in committed code.

## Branches and PRs

- Branch from `main`: `feat/...`, `fix/...`, or `chore/...`.
- Keep PRs small and single-purpose.
- Fill in the PR template: what changed, why, linked issue, and screenshots
  for UI changes.
- CI must be green (`flutter analyze` + `flutter test`) before merge.

## Releasing

Releases are owner-only, but the mechanics are documented here so the process
is transparent.

- **Versioning:** [Semantic Versioning](https://semver.org). The `version:`
  field in `pubspec.yaml` is the source of truth (`0.1.0+1` = version
  `0.1.0`, build `1`).
- **Tags:** release tags are `vX.Y.Z` and must equal the pubspec version
  (without the `+build` suffix) — `release.yml` fails the run otherwise.
- **Changelog:** add a `## [X.Y.Z] - YYYY-MM-DD` section to `CHANGELOG.md`
  before tagging; the workflow publishes it as the release notes.
- **Workflow:** pushing a `v*` tag triggers
  `.github/workflows/release.yml`, which builds the signed release APK and
  creates a GitHub Release with the APK attached.
- **Secrets:** release signing needs four repository secrets (names only —
  the values never leave the owner's machine): `KEYSTORE_BASE64`,
  `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, and `KEY_ALIAS` (`pakainiat`). Until
  the owner sets them, tagged releases fail at the signing step.

## Issues

Bug reports and feature requests use the provided templates. Include Flutter
version and device info for bugs — it saves a round trip.
