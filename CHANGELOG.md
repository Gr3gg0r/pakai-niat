# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Parser now defaults to `deepseek/deepseek-v4-flash` (with `deepseek/deepseek-v4-pro` fallback); free models remain as last resort
- Requests route through OpenRouter's fastest provider (`provider.sort: throughput`) — roughly 2-3x faster parsing

## [0.1.0] - 2026-07-13

### Added

- Initial public release
- AI natural-language capture via OpenRouter — type a sentence, get a structured task, habit, or idea
- Today, Habits, and Ideas views
- Local-first storage with Isar — everything stays on device
- OpenRouter parser with model fallback chain
- Brand identity: app icons, native splash, honey/mint theme
- Landing page at [gr3gg0r.github.io/pakai-niat](https://gr3gg0r.github.io/pakai-niat/)

[Unreleased]: https://github.com/Gr3gg0r/pakai-niat/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Gr3gg0r/pakai-niat/releases/tag/v0.1.0
