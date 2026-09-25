# Changelog

Notable changes to this fork of Omnimo. Upstream predates this file, so the
first entry covers everything the fork has changed so far.

## [0.1.0] - 2026-09-25

### Added

- Simplified Chinese for the settings UI and the panel context menus, carried
  by a language pack (`EnglishChinese.inc`) rather than by per-configuration
  overrides, so menus inside the panels switch with the language setting too.
  Tile surfaces stay English: they are laid out around English string widths,
  and the seven keys that appear on both a surface and in the interface keep
  their English values.
- Simplified Chinese language file for the AutoIt tools.
- Agenda panel: reads up to three published ICS calendar subscriptions, merges
  and deduplicates them, and lists today plus the following six days grouped
  by day, with wheel scrolling and a return to the top after it goes idle.
  Ships in the square, double and doubleV size tiers.
- `LICENSE` (GPL-2.0) and `THIRD-PARTY.md`, which records per-file provenance
  for the media, binaries, fonts and AutoIt includes the repository carries.
- `AGENTS.md`, a working guide to this fork.

### Changed

- The language picker offers 简体中文 where the `[Help Translate]` entry used
  to be. Upstream's translation project is no longer maintained, so the entry
  it replaced had nothing left to point at.
- The Network panel pings a literal IPv4 address by default. Rainmeter does not
  get a reply from a host name in this environment, so the panel reported a
  failed measurement as if it were a latency.

### Fixed

- Panel text that ran past the tile edge. The size-tier geometry adds its
  ten-pixel allowance to one axis only, and the clipping mask now matches it.
- Calendar-style lists repeating "all day" was left alone; the underlying
  defect was that merged feeds were never re-sorted, so events appeared
  grouped by calendar instead of in time order.
- Two `Hidden=` expressions in the DigitalClock panel that read the setting
  inverted, and a `FontSize` formula with an empty operand that logged a parse
  error on every update.
- Twelve panels calling a `GetMhz` measure that no longer exists (a plugin for
  it was removed upstream), which logged a script error on every load.
- A `Ping` meter whose auto-scaled unit was injected into the numeric format,
  turning milliseconds into "kms" past 1024.
