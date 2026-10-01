<p align="center"><strong>English</strong> · <a href="README.zh.md">中文</a></p>

<div align="center">

<img src="https://raw.githubusercontent.com/OMSociety/Omnimo/master/Rainstaller.bmp" width="480" alt="ReOmnimo banner" />

# ReOmnimo

**A Windows Phone 7 inspired interactive desktop information center for Rainmeter** — taking over development of Omnimo.

[![Version](https://img.shields.io/github/v/tag/OMSociety/Omnimo?label=version&color=blue)](https://github.com/OMSociety/Omnimo/releases)
[![Rainmeter](https://img.shields.io/badge/Rainmeter-%E2%89%A54.3-green.svg)](https://www.rainmeter.net/)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Stars](https://img.shields.io/github/stars/OMSociety/Omnimo)](https://github.com/OMSociety/Omnimo/stargazers)
[![Issues](https://img.shields.io/github/issues/OMSociety/Omnimo)](https://github.com/OMSociety/Omnimo/issues)

[What is ReOmnimo?](#what-is-reomnimo) • [What changed](#what-changed) • [Install](#install) • [Agenda panel](#agenda-panel) • [Development](#development) • [Changelog](CHANGELOG.md) • [中文](README.zh.md)

</div>

---

## What is ReOmnimo?

**ReOmnimo** is a Windows Phone 7 inspired multifunctional interactive desktop information center based on [Rainmeter](https://www.rainmeter.net/). It turns your desktop into a productive and attractive work area, delivering only the information you need. Every interactive tile gives you information and settings at a glance, and can be customized to your needs — unlike the initial Metro design, ReOmnimo gives you limitless customization potential.

ReOmnimo takes over development of [Omnimo](https://github.com/fediaFedia/Omnimo) by fediaFedia and Xyrfo. The design and the panel set stay as they are; the changes are listed below.

## What changed

| Change | Description |
|--------|-------------|
| **Simplified Chinese UI** | The settings and save panels and the panel context menus are localized into Simplified Chinese. Tile surfaces stay English, because they are laid out around English string widths; the one exception is the Agenda tile, whose name is localized through its gallery entry (日程 in this mode). The language picker offers 简体中文 for this mode. |
| **Agenda panel** | Reads published ICS calendar subscriptions (up to three per panel, merged and sorted by time). Private CalDAV endpoints need PROPFIND, which Rainmeter cannot issue; a published subscription URL is a plain GET and works. |
| **Panel defect fixes** | A handful of long-standing panel defects fixed; see `CHANGELOG.md`. |
| **Licensing in order** | `LICENSE` (GPL-2.0) and `THIRD-PARTY.md` brought in order. |

## Install

ReOmnimo ships as a Rainmeter skin suite. Install [Rainmeter](https://www.rainmeter.net/) 4.3 or later, then load the suite through Rainmeter's skin management. The `Rainstaller.cfg` at the repository root describes the package (`MinRainmeterVer=4.3`).

> **Note:** The desktop mapping expects the suite under `Documents\Rainmeter\Skins\WP7`. See `AGENTS.md` for the working setup.

## Agenda panel

The Agenda panel subscribes to published ICS calendars and renders the coming days as a scrolling list.

- Up to three subscription URLs per panel, merged and sorted by time.
- Recurring events (`RRULE`) are expanded for a bounded subset (`DAILY`/`WEEKLY`/`MONTHLY`/`YEARLY` with `INTERVAL`/`COUNT`/`UNTIL`/`BYDAY`/`BYMONTHDAY`/`BYMONTH`); anything else falls back to the single `DTSTART` instance.
- Event times are converted to local time through a built-in fixed-offset table; the offsets do not follow daylight saving, so some zones can be an hour off during DST — a deliberate trade-off.
- `RangeDays` is the exact number of calendar days shown.

> **Note:** A published calendar subscription URL is a credential in itself. Do not commit it to any tracked file; keep it in the untracked `UserVariables.local.inc`. See `AGENTS.md`.

## Development

Read `AGENTS.md` first. It records the file encodings, the Rainmeter behaviours that bite, and the credential rules that apply to calendar subscription URLs.

## Changelog

Per-release changes are listed in [`CHANGELOG.md`](CHANGELOG.md).

## Credits

Omnimo is by [fediaFedia](https://github.com/fediaFedia) and Xyrfo, with contributions from Marko C., Giblet, Varelse42, poiru, and the Rainmeter work of jsmorley, Smurfier and theAzack9.

## License

- Software and components: [GPL-2.0](LICENSE)
- Images and media: [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/)

ReOmnimo is maintained under [OMSociety](https://github.com/OMSociety/Omnimo).
