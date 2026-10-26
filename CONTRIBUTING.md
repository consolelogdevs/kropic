# Contributing to Kropic

Thanks for helping. A few notes on how the project works.

## Setup

See [Build and run](README.md#build-and-run). Run `xcodegen generate` after adding or removing files or changing `project.yml`; the `.xcodeproj` is generated and never committed.

## Before you open a pull request

- `swift test --package-path Packages/KropicCore` passes
- The app builds without warnings (Swift 6 strict concurrency is on)
- Logic that does not need AppKit goes into `KropicCore` with tests
- Colors come from the asset catalog, every screen works in light and dark
- User facing text is localizable; run `Scripts/sync-strings.sh` after changing it
- Non-obvious decisions get an entry in [`docs/DECISIONS.md`](docs/DECISIONS.md)

## Ground rules

- Apple frameworks only for core features; ask in an issue before adding a dependency
- Captured images never touch disk unless the user saves them
- Keep personal data such as team IDs out of committed files (`Configs/Local.xcconfig` is ignored)

The full working rules are in [CLAUDE.md](CLAUDE.md), and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) explains how the parts fit together.
