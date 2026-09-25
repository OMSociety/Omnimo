# Third-Party Notices

This repository is a fork of [fediaFedia/Omnimo](https://github.com/fediaFedia/Omnimo). It carries the
upstream tree essentially verbatim, plus a Simplified Chinese localization and a small set of source
fixes. This file records where every part comes from and under what terms it is redistributed.

The repository root [`LICENSE`](LICENSE) holds the **GNU General Public License version 2** text, which
governs the software and components, exactly as upstream declares it in its `readme.md`.

---

## 1. Upstream Omnimo

**Provenance.** The tree under `WP7/`, `AutoIT/` and `Extra/`, plus `Rainstaller.bmp` and
`Rainstaller.cfg`, comes from <https://github.com/fediaFedia/Omnimo>, default branch `master`, last
commit `d6a69f1e` (2024-05-16). `upstream` is kept as a git remote so every file stays individually
traceable to its upstream author, and so upstream changes can still be merged.

**What upstream declares.** The upstream repository has **no `LICENSE` file** — GitHub reports
`license: null`. The only repository-level statement is a section of upstream's `readme.md`:

> **LICENSE**
> Software and Components — [GPL v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
> Images and Media — [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/)

**What the files themselves declare.** Independently of that, most `.ini` files under `WP7/` carry a
`[Metadata] License=` line. Counted on this repository's tree:

| Declaration | Files |
|---|---|
| `Creative Commons Attribution-Noncommercial-Share Alike 3.0 License` | 592 |
| `Creative Commons Attribution-Non-Commercial-Share Alike 3.0` (same licence, different spelling) | 2 |
| `Creative Commons Attribution-NonCommercial-NoDerivs 3.0` | 3 |
| `License=` present but empty | 2 |
| **`.ini` carrying a declaration** | **599** |
| `.ini` with no `License=` line at all | 22 |

The two statements disagree in scope: `readme.md` puts "software and components" under GPL-2.0, while
almost every individual `.ini` self-declares as CC BY-NC-SA 3.0. Where a file carries its own
declaration we treat that declaration as governing that file; where it carries none we only record
upstream's blanket statement and claim no rights of our own. The conflict is listed as an open item in
section 8.

The **3 NoDerivs files** are the only upstream files whose licence forbids modification. They are
carried unmodified:

```
WP7/TextItems/Search/Item.ini
WP7/TextItems/Search/ItemDark.ini
WP7/TextItems/Search/ItemTransparent.ini
```

**Files with no declaration at all.** Beyond the 22 `.ini` files listed above, these formats cannot
carry a declaration or do not have one anywhere in the tree:

| Group | Count | Note |
|---|---|---|
| `.inc` / `.lua` / `.cfg` / `.js` | 548 / 9 / 398 / 4 | No `[Metadata]` section exists in these formats |
| `.png` / `.jpg` / `.gif` / `.ico` / `.bmp` / `.thm` | 1434 / 103 / 21 / 100 / 5 / 7 | No sidecar licence anywhere in the tree |
| `.txt` / `.html` / `.url` / `.lnk` / `.bat` / `.wav` / `.xml` | 60 / 3 / 2 / 12 / 2 / 1 / 1 | Various; no licence stated |
| `.exe` / `.ttf` | 7 / 1 | See sections 3 and 4 |

## 2. This fork's own changes

Measured with `git diff --name-status upstream/master`: **14 files added, 46 modified, 16 deleted.**

Added:

| File | What it is |
|---|---|
| `LICENSE` | The GPL-2.0 text, matching the licence upstream's readme declares |
| `AGENTS.md` | A working guide to this fork: encodings, Rainmeter pitfalls, credential rules |
| `CHANGELOG.md` | Per-release notes for the fork |
| `THIRD-PARTY.md` | This file |
| `WP7/@Resources/Common/Variables/Languages/Chinese.inc` | Simplified Chinese UI language pack, 284 keys, mirroring `English.inc` |
| `WP7/@Resources/Common/Background/Language/Chinese.cfg` | Simplified Chinese strings for the AutoIt tools, 33 keys |
| `AutoIT/Language/Chinese.cfg` | The same pack kept beside the AutoIt sources |
| `WP7/Panels/Agenda/` (`Item.ini`, `Item2.ini`, `Item3.ini`, `agenda.lua`, `Agenda.png`) | The Agenda calendar panel: published ICS subscriptions, merged, deduplicated and sorted |
| `WP7/@Resources/Config/Panels/Agenda/` (`UserVariables.inc`, `RainConfigure.cfg`) | Its user parameters and settings schema |

Modified: seven language packs (a `PanelAgenda` key each), the gallery registration
(`WP7/Gallery/cat1.inc`, `WP7/Gallery/cat7.inc`, `WP7/Gallery/Intro/intro.ini`), the shared
icon layer (`WP7/@Resources/Graphics/Gallery/mask-essential.png`), three default-value files
(`WP7/@Resources/Common/Variables/UserVariables.inc`, `WP7/@Resources/Common/Color/color.inc`,
`WP7/@Resources/Config/Panels/Network/UserVariables.inc`), 27 panel files under `WP7/Panels/`
— thirteen of them (eight HDD, four RAM, one Multimeter) dropped a dangling
`!CommandMeasure GetMhz "Run"` call, only the RAM panel's second tier having defined that
measure and no meter having displayed its value, so the other twelve spawned an unused
`wmic MemoryChip` child process on every refresh; the Slideshow and DigitalClock panels now
carry the same base `Height` across every size tier, so a card no longer jumps when the
Alternative menu switches tier; the Volume panel's progress bar is recentered in the single
and halfsingle tiers, where the tile background adds `#Padding#` on both sides but the bar's
origin did not add it back; plus a `FontSize` expression with an empty operand in
DigitalClock4, a byte/bit suffix and a dropped `AutoScale` in the Network panel, and two
`Hidden` lines in the Network panel that contradicted their settings toggle — the two AutoIt
tool sources (`AutoIT/OmnimoApp.au3`, whose folder/app pickers passed `StringReplace`'s
arguments in the wrong order so the choice went to a stray file and the panel config was
never updated, and `AutoIT/Config.au3`, whose border-color branch read an undeclared
variable instead of the color picker's result) and the two shipped executables they build,
`OmnimoApp.exe` and `config.exe`, rebuilt with AutoIt 3.3.8.1 so those fixes reach the
binaries users run (see section 3), and `readme.md`.

Deleted: the Corona panel — four files under `WP7/Panels/Corona/` and six under
`WP7/@Resources/Config/Panels/Corona/`, removed at the user's request, with the gallery row
and the icon layer reflowed to match; and the six Microsoft Segoe `.ttf` files under
`WP7/@Resources/Fonts/`, not licensed for redistribution and never loaded by the skin (see
section 4).

Our changes inherit the terms of the file they touch: GPL-2.0 where upstream puts that file under
GPL-2.0, CC BY-NC-SA 3.0 where the file self-declares it. No rights are claimed over upstream
material.

## 3. Bundled executables

Seven executables ship inside the repository. They are upstream's own AutoIt helper GUIs, built from
the sources in `AutoIT/`; the binaries themselves carry no source and no declared licence.

```
WP7/@Resources/Common/ColorChanger.exe                       786961 bytes
WP7/@Resources/Common/OmnimoApp.exe                          775247 bytes
WP7/@Resources/Common/Background/ConfigBackground.exe        788363 bytes
WP7/@Resources/Common/Config/ActivePanels.exe                938496 bytes
WP7/@Resources/Common/Config/config.exe                      757151 bytes
WP7/@Resources/Common/MultiManager/MultiManager.exe          1022976 bytes
WP7/@Resources/Common/PanelCreator/PanelCreator.exe          1051419 bytes
```

Upstream let `config.exe` drift from its source: the binary was committed on 2020-05-18, while
`AutoIT/Config.au3` was changed again on 2020-05-26 without a rebuild, and the released `.rmskin`
ships a newer `Config.exe` that is not in upstream's git history at all. This fork rebuilds the two
executables whose sources it modified — `OmnimoApp.exe` and `config.exe` — with AutoIt 3.3.8.1
(`Aut2Exe`, x86, no UPX, the sources' own icons), matching the interpreter version embedded in the
originals; the other five remain upstream's builds.

## 4. Bundled fonts

Upstream shipped seven font files here: six Microsoft Segoe faces plus `OptimusPrinceps.ttf`. The six
Segoe files were never licensed for redistribution, so this fork drops them and keeps only
`OptimusPrinceps.ttf`, which is not a Microsoft face.

```
OptimusPrinceps.ttf       41416 bytes   not a Microsoft face
```

Nothing in the skin loaded the Segoe files: Rainmeter resolves a meter's `FontFace` by system font
name, and no `.ini`, script or installer in the tree referenced `Fonts/` or those filenames, so they
were inert payload rather than a font the skin installed. Dropping them therefore does not change how
the skin renders — the faces were always resolved from the system.

One caveat is unchanged by the removal: Segoe WP is not a Windows default, so on a system without it
the panels that name it (`FontFace=Segoe WP …`, reached through the `#FontTypeWP#` variable) fall back
to whatever substitute the system provides. That was already the behaviour, since the bundled files
were never installed. Listed in section 8.

## 5. AutoIt user-defined functions

`AutoIT/Includes/` bundles UDFs written by AutoIt community members. They are redistributed with the
author attribution the files themselves carry; none of them states an explicit licence.

| File | Bytes | Author as declared in the file |
|---|---|---|
| `WinAPIEx.au3` | 1691123 | Yashied |
| `APIConstants.au3` | 225396 | Yashied |
| `ColorChooser.au3` | 52877 | Yashied |
| `_Zip.au3` | 38995 | wraithdu |
| `IconImage.au3` | 38380 | Ward |
| `Binary.au3` | 26719 | Ward |
| `DragDropEvent.au3` | 18024 | Ward |
| `MouseOnEvent.au3` | 14840 | G.Sandler (MrCreatoR) |
| `_Startup.au3` | 11656 | guinness |
| `ColorGenerator.au3` | 2509 | not stated |
| `Common.au3` | 2486 | not stated |

## 6. Rainmeter

Rainmeter and its bundled plugins are **GPL-2.0-only** and are **not** redistributed here. A skin is a
set of data files the engine loads; it is not a derivative work of the engine, so this repository's
licensing is not determined by Rainmeter's.

## 7. Attribution

- **Omnimo / fediaFedia** — the design this fork is based on and the source of almost every file.
- **Yashied, Ward, wraithdu, guinness and MrCreatoR** — the AutoIt UDFs in `AutoIT/Includes/`.
- The upstream Omnimo translators, credited inside each language pack's `Translated=` key. The
  Simplified Chinese packs carry `Translated=OMSociety`.

## 8. Open items

| # | Item | Status |
|---|---|---|
| 1 | Upstream's GPL-2.0 vs CC BY-NC-SA 3.0 statement conflict | Recorded in section 1; per-file declarations treated as governing that file. |
| 2 | 22 `.ini` plus 960 `.inc`/`.lua`/`.cfg`/`.js` and 1670 images with no declaration | Carried as-is with provenance traceable through the retained git history. No rights claimed. |
| 3 | 7 upstream `.exe` with no source and no declared licence | Repository-only. Closes if the binaries are dropped and users build from `AutoIT/`. |
| 4 | ~~6 Microsoft Segoe `.ttf` in `WP7/@Resources/Fonts/`~~ | Resolved: the six files are removed. The skin resolved those faces by system name and never loaded the files, so nothing renders differently; the Segoe WP fallback on systems without that face is unchanged. |
| 5 | The repository has no README of its own; upstream's `readme.md` is unchanged | A short note that this is a fork with a Chinese localization is not yet written. |

---

## Appendix — how the figures above were produced

Run from the repository root. `.ini` files under `WP7/` are not all UTF-8, so the read is BOM-aware:

```powershell
function Read-Txt($p) {
  $b = [IO.File]::ReadAllBytes($p)
  if ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { return [Text.Encoding]::Unicode.GetString($b, 2, $b.Length - 2) }
  if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { return [Text.Encoding]::UTF8.GetString($b, 3, $b.Length - 3) }
  return [Text.Encoding]::GetEncoding(1252).GetString($b)
}

$files = Get-ChildItem 'WP7' -Recurse -File
$lic = @{}; $none = 0; $empty = 0
foreach ($f in ($files | Where-Object { $_.Extension -eq '.ini' })) {
  $m = [regex]::Match((Read-Txt $f.FullName), '(?im)^[ \t]*License[ \t]*=[ \t]*(.*?)[ \t]*\r?$')
  if (-not $m.Success) { $none++; continue }
  $v = $m.Groups[1].Value.Trim()
  if ($v -eq '') { $empty++ } else { $lic[$v] = 1 + ($lic[$v] -as [int]) }
}
$lic.GetEnumerator() | Sort-Object Value -Descending
"no License= line: $none   empty value: $empty"
```

> **Note:** the regex must anchor the value to its own line. A looser pattern such as
> `^\s*License\s*=\s*(.*?)\s*$` swallows the following line — the `.ini` metadata blocks put
> `Variant=` right after `License=` — which turns the two genuinely empty declarations into a bogus
> `Variant=` value and inflates the total.

The change set in section 2 comes from `git diff --name-status upstream/master -- .`.
