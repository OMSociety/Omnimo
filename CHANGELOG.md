# Changelog

Notable changes to this fork of Omnimo. Upstream predates this file, so the
first entry covers everything the fork has changed so far.

## [0.1.1] - 2026-09-25

### Added

- The calendar panel now appears in the Date and Time row of the common panels
  page, next to Stopwatch, with its own calendar glyph in the shared icon layer
  and its tile name localized to 日程. It fills a cell that upstream's icon
  layer left blank.

### Changed

- The default theme carries the values the desktop was laid out against:
  `Padding=5` instead of `0`, a lighter card, no backdrop blur, and titles
  closer to the edge. Card width is `(#Height# + #Padding# * 2)`, and that
  value comes only from the theme, so at zero every panel drew ten logical
  pixels narrower and inset by five.
- The Slideshow panel's base height returns to 196 and the digital clock's to
  160, matching the release the layout came from. Only the one tier file each
  layout loads was changed; the panels' other size tiers keep 150. A card at
  150 is a quarter narrower, which is why the picture no longer lined up with
  the column below.
- The calendar panel's registration was removed from the custom panels list,
  where it was a leftover from the first attempt; it belongs to the common
  panels page, which is a hand-authored list rather than a registered one.
- `AGENTS.md` rewritten around the findings above, with the measured cell
  geometry of the gallery icon layer and the reference points for the settings
  schema, the size tiers and the desktop layout.

### Fixed

- The calendar panel could not be scrolled: the wheel actions that the
  prototype carried were lost when the panel files were generated. They are
  back in the `[Rainmeter]` section of all three size tiers.
- The panel's calendar feeds were fetched before their addresses were
  rewritten, which logged a fetch error on every load. The measures now start
  disabled and the script enables them once the address is in place.
- Merged calendar feeds were not re-sorted after deduplication, so events from
  different subscriptions interleaved instead of appearing in time order.

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
- Thirteen panel tiers ran a `GetMhz` measure on every refresh. Only the RAM
  panel's second tier defined it, and no meter displayed its value, yet it
  spawned a `wmic MemoryChip` child process on every refresh; the other twelve
  calls were dangling. All thirteen call sites and the one measure are removed.
- A `Ping` meter whose auto-scaled unit was injected into the numeric format,
  turning milliseconds into "kms" past 1024.
