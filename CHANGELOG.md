# Changelog

Notable changes to this fork of Omnimo. Upstream predates this file, so the
first entry covers everything the fork has changed so far.

## [Unreleased]

### Fixed

- Volume panel: the bottom progress bar sat off-center in the single and
  halfsingle tiers. The tile background adds `#Padding#` on both sides, but the
  bar's origin did not add it back, so the bar was shifted left by one padding
  unit; the origin now includes it and the bar centers under the tile.
- Agenda panel: events exported with a UTC (`Z`) timestamp were placed at the
  raw clock time instead of the local one, shifting them by the UTC offset. The
  parser now converts `Z` times to local.
- Agenda panel: a subscription that never returned a valid calendar sat on
  "loading feed..." forever. After a 45-second timeout with no data the panel
  now reports the feed as unavailable; a source that had already shown events
  keeps its last content rather than reverting to the timeout message.
- The shipped `OmnimoApp.exe` and `config.exe` are now rebuilt from the
  corrected sources with AutoIt 3.3.8.1 (`Aut2Exe`, x86, no UPX, the sources'
  own icons), the interpreter version embedded in the originals. The 0.2.0
  source-only fixes to the folder/app picker and the border-color branch now
  reach the binaries users actually run.

### Changed

- Panel size tiers: the digital clock's and the slideshow's base `Height` is
  now the same across every tier, so a card keeps its proportions whichever
  layout loads it.
- The Simplified Chinese language pack was renamed from `EnglishChinese.inc` to
  `Chinese.inc`; references updated to match.
- Chinese coverage of the settings and configuration strings was extended by 21
  keys (among them `24HourTime`, the limited-mode `Missing` notices and the
  panel-creator labels). Tile surfaces and the Donate panel's author note stay
  English by design.
- Agenda panel: private calendar subscriptions now load from a gitignored
  `UserVariables.local.inc` override that falls back to the committed public
  defaults when absent. A published calendar URL grants read access to that
  calendar, so keeping personal feeds in a local, uncommitted file stops them
  from ever entering the repository.
- Removed the six bundled Microsoft Segoe font files from
  `@Resources/Fonts/`, which Microsoft does not license for redistribution.
  The skin resolves font faces by system name and never loaded the files, so
  nothing renders differently; `OptimusPrinceps.ttf`, not a Microsoft face,
  stays.

## [0.2.0] - 2026-09-26

### Fixed

- RSS and other text feeds rendered `?` in place of ä, ö and –: the three
  substitution targets in the shared feed table had lost their characters
  together with their closing quotes in an encoding pass, which also left the
  table's quotes unbalanced for every meter consuming it.
- The Intro wizard's 简体中文 entry wrote `MainLanguage English`, switching the
  interface back to English. It now writes `EnglishChinese`, matching the
  gallery's language list.
- DigitalClock4 hid the clock exactly when "show seconds" was ticked: its
  `Hidden` expression contradicted the settings checkbox, which writes 0 when
  the option is enabled. The same suspicion against `Item.ini` did not survive
  reading the checkbox write code; that file was correct as shipped.
- The Network panel's grid toggle hid the grid when ticked. Both tiers now
  follow the setting.
- Agenda panel: the empty-range message hard-coded 7 days while the window is
  configurable (6 by default); a panel with no feeds configured sat on
  "loading feed..." forever; a dead subscription answering with an HTML error
  page was reported as "no events in the next N days"; all-day events exported
  with a date-time end rendered as "00:00-HH:MM"; the hint text was the only
  meter in the tier ignoring the DPI scale.
- AutoIt sources: OmnimoApp's folder/app pickers passed `StringReplace`'s
  arguments in the wrong order, so the user's choice went to a stray file and
  the panel's configuration was never updated; the settings tool's
  border-color branch read an undeclared variable and discarded the chosen
  color. Both fixes are source-only; the shipped binaries are unchanged, the
  same situation THIRD-PARTY.md section 3 already records for config.exe.

### Changed

- AGENTS.md rewritten around measured facts: the settings checkbox's write
  contract, the encoding and line-ending census, the six skip-worktree files,
  corrected diff counts, and a panels.inc example that matches the tree.
- THIRD-PARTY.md's change-set section regenerated from the actual diff; the
  fictitious ChineseUI.inc entry is gone and the Corona deletions are listed.
- The readme now notes the one exception to English tile surfaces: the Agenda
  tile's name is localized through its gallery entry.
- The 0.1.1 entry below was corrected in place: the calendar tile fills a cell
  upstream's icon layer left blank rather than replacing the digital clock;
  the height revert touched only the tier each layout loads; the GetMhz
  entry's causality (an unused per-refresh `wmic` child process, not a removed
  plugin).

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
