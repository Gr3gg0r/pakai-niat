# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

Please do not open a public issue for security problems. Instead, open a
[private security advisory](https://github.com/Gr3gg0r/pakai-niat/security/advisories/new)
on GitHub.

You'll get an acknowledgement as soon as possible (this is a solo-maintained
project, so response times vary). If a report is confirmed, a fix will be
released and you'll be credited in the advisory unless you prefer otherwise.

## Secrets

Pakai Niat bundles **no secrets or API keys** in the app or the repository.
AI capture is powered by OpenRouter, and each user must supply their own
`OPENROUTER_KEY` via a local `.env` file (see `.env.example`). `.env` is
gitignored — never commit it. If you ever find a key committed to the repo,
please report it through the channels above so it can be revoked and scrubbed.

## Release signing

Release builds are signed with a keystore that lives **outside** the
repository. The gitignored `android/key.properties` points the local Gradle
build at that keystore; CI release builds decode it from GitHub Actions
secrets instead:

- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`

Only the secret *names* are documented here — the values live in GitHub
Actions secrets and the maintainer's local records. `.env`,
`android/key.properties`, and `*.keystore` / `*.jks` files never ship; CI
fails any push that tracks one of them (see `.github/workflows/ci.yml`).

## Operational security notes

- **Keys in shared APKs.** `.env` is bundled as a Flutter asset, so any APK
  built with a real `.env` contains `OPENROUTER_KEY` — anyone holding the APK
  can extract it. When sharing builds (e.g. with family), build with a
  *separate* OpenRouter key that has a low credit/rate limit, and rotate it if
  it leaks. Runtime key entry (no bundled key at all) is planned.
- **Never build for web with a real `.env`.** `flutter build web` would
  publish the key as a publicly downloadable asset.
- **Transport.** HTTPS-only: Android sets
  `android:usesCleartextTraffic="false"`; iOS relies on the default App
  Transport Security policy (no exceptions configured).
- **Local data.** The Isar database is stored unencrypted on-device — the
  device lock is the trust boundary. Android cloud backup of app data is
  disabled (`android:allowBackup="false"`).
