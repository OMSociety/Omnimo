<p align="center"><strong>English</strong> · <a href="#中文">中文</a></p>

<div align="center">

<img src="https://raw.githubusercontent.com/OMSociety/Omnimo/master/Rainstaller.bmp" width="480" alt="Omnimo banner" />

# Omnimo

**A Windows Phone 7 inspired interactive desktop information center for Rainmeter** — this fork keeps upstream's design and panel set, and changes only four things.

[![Version](https://img.shields.io/github/v/tag/OMSociety/Omnimo?label=version&color=blue)](https://github.com/OMSociety/Omnimo/releases)
[![Rainmeter](https://img.shields.io/badge/Rainmeter-%E2%89%A54.3-green.svg)](https://www.rainmeter.net/)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Stars](https://img.shields.io/github/stars/OMSociety/Omnimo)](https://github.com/OMSociety/Omnimo/stargazers)
[![Issues](https://img.shields.io/github/issues/OMSociety/Omnimo)](https://github.com/OMSociety/Omnimo/issues)

[What this fork changes](#what-this-fork-changes) • [Install](#install) • [Agenda panel](#agenda-panel) • [Changelog](CHANGELOG.md) • [中文](#中文)

</div>

---

## What is Omnimo?

**Omnimo** is a Windows Phone 7 inspired multifunctional interactive desktop information center based on [Rainmeter](https://www.rainmeter.net/). It turns your desktop into a productive and attractive work area, delivering only the information you need. Every interactive tile gives you information and settings at a glance, and can be customized to your needs — unlike the initial Metro design, Omnimo gives you limitless customization potential.

This repository is a fork of [fediaFedia/Omnimo](https://github.com/fediaFedia/Omnimo). It keeps upstream's design and panel set, and changes only four things.

## What this fork changes

| Change | Description |
|--------|-------------|
| **Simplified Chinese UI** | The settings and save panels and the panel context menus are localized into Simplified Chinese. Tile surfaces stay English, because they are laid out around English string widths; the one exception is the Agenda tile, whose name is localized through its gallery entry (日程 in this mode). The language picker offers 简体中文 for this mode. |
| **Agenda panel** | Reads published ICS calendar subscriptions (up to three per panel, merged and sorted by time). Private CalDAV endpoints need PROPFIND, which Rainmeter cannot issue; a published subscription URL is a plain GET and works. |
| **Panel defect fixes** | A handful of long-standing panel defects fixed; see `CHANGELOG.md`. |
| **Licensing in order** | `LICENSE` (GPL-2.0) and `THIRD-PARTY.md` brought in order. |

## Install

Omnimo ships as a Rainmeter skin suite. Install [Rainmeter](https://www.rainmeter.net/) 4.3 or later, then load the suite through Rainmeter's skin management. The `Rainstaller.cfg` at the repository root describes the package (`MinRainmeterVer=4.3`).

> **Note:** This fork's desktop mapping expects the suite under `Documents\Rainmeter\Skins\WP7`. See `AGENTS.md` for the working setup.

## Agenda panel

The Agenda panel subscribes to published ICS calendars and renders the coming days as a scrolling list.

- Up to three subscription URLs per panel, merged and sorted by time.
- Recurring events (`RRULE`) are expanded for a bounded subset (`DAILY`/`WEEKLY`/`MONTHLY`/`YEARLY` with `INTERVAL`/`COUNT`/`UNTIL`/`BYDAY`/`BYMONTHDAY`/`BYMONTH`); anything else falls back to the single `DTSTART` instance.
- Event times are converted to local time through a built-in fixed-offset table; the offsets do not follow daylight saving, so some zones can be an hour off during DST — a deliberate trade-off.
- `RangeDays` is the exact number of calendar days shown.

> **注意：** A published calendar subscription URL is a credential in itself. Do not commit it to any tracked file; keep it in the untracked `UserVariables.local.inc`. See `AGENTS.md`.

## Working on this fork

Read `AGENTS.md` first. It records the file encodings, the Rainmeter behaviours that bite, and the credential rules that apply to calendar subscription URLs. `CHANGELOG.md` lists the changes per release.

## License

- Software and components: [GPL-2.0](LICENSE)
- Images and media: [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/)

## Credits

Omnimo is by [fediaFedia](https://github.com/fediaFedia) and Xyrfo, with contributions from Marko C., Giblet, Varelse42, poiru, and the Rainmeter work of jsmorley, Smurfier and theAzack9. This fork is maintained under [OMSociety](https://github.com/OMSociety/Omnimo).

---

<a id="中文"></a>

<p align="center"><a href="#omnimo">English</a> · <strong>中文</strong></p>

<div align="center">

# Omnimo(中文本地化 fork)

**基于 Rainmeter 的 Windows Phone 7 风格交互式桌面信息中心** —— 本 fork 保留上游的设计与面板集,只改四件事。

</div>

## Omnimo 是什么

**Omnimo** 是一套基于 [Rainmeter](https://www.rainmeter.net/) 的 Windows Phone 7 风格多功能交互式桌面信息中心。它把桌面变成高效又好看的工作区,只呈现你需要的信息。每一块可交互磁贴都能一眼给出信息与设置,并可按你的需要定制 —— 与最初的 Metro 设计不同,Omnimo 给了你几乎无限的定制空间。

本仓库是 [fediaFedia/Omnimo](https://github.com/fediaFedia/Omnimo) 的 fork,保留上游的设计与面板集,只改四件事。

## 本 fork 的改动

| 改动 | 说明 |
|------|------|
| **简体中文界面** | 设置与保存面板、面板右键菜单本地化为简体中文。磁贴表面保持英文,因为它们按英文宽度排版;唯一例外是日程磁贴,其名称经面板库条目本地化(此模式下为「日程」)。语言选择器为此模式提供「简体中文」。 |
| **日程面板** | 读取公开的 ICS 日历订阅(每个面板最多三条,按时间合并排序)。私有 CalDAV 端点需要 PROPFIND,而 Rainmeter 无法发起;公开的订阅 URL 是普通 GET,可以工作。 |
| **面板缺陷修复** | 修了一批长期存在的面板缺陷,见 `CHANGELOG.md`。 |
| **许可理顺** | 补齐 `LICENSE`(GPL-2.0)与 `THIRD-PARTY.md`。 |

## 安装

Omnimo 以 Rainmeter 皮肤套件分发。先安装 [Rainmeter](https://www.rainmeter.net/) 4.3 或更高版本,再经 Rainmeter 的皮肤管理加载本套件。仓库根的 `Rainstaller.cfg` 描述了该包(`MinRainmeterVer=4.3`)。

> **注意:** 本 fork 的桌面映射要求套件位于 `Documents\Rainmeter\Skins\WP7`,工作配置见 `AGENTS.md`。

## 日程面板

日程面板订阅公开的 ICS 日历,把未来几天渲染成可滚动的列表。

- 每个面板最多三条订阅 URL,按时间合并排序。
- 重复事件(`RRULE`)按有界子集展开(`DAILY`/`WEEKLY`/`MONTHLY`/`YEARLY` 加 `INTERVAL`/`COUNT`/`UNTIL`/`BYDAY`/`BYMONTHDAY`/`BYMONTH`);其它规则退回只画 `DTSTART` 那一条。
- 事件时间经内置固定偏移表换算到本机时间;偏移不跟夏令时走,部分区域在夏令时期间可能差一小时,这是刻意取舍。
- `RangeDays` 是显示的确切日历日天数。

> **注意:** 公开的日历订阅 URL 本身就是凭据,不要提交进任何被跟踪文件,放在未跟踪的 `UserVariables.local.inc` 里。详见 `AGENTS.md`。

## 参与本 fork

先读 `AGENTS.md`,其中记录了文件编码、会踩坑的 Rainmeter 行为,以及适用于日历订阅 URL 的凭据规则。`CHANGELOG.md` 按版本列出改动。

## 许可证

- 软件与组件:[GPL-2.0](LICENSE)
- 图像与媒体:[CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/)

## 致谢

Omnimo 由 [fediaFedia](https://github.com/fediaFedia) 与 Xyrfo 创作,感谢 Marko C.、Giblet、Varelse42、poiru 的贡献,以及 jsmorley、Smurfier、theAzack9 在 Rainmeter 上的工作。本 fork 由 [OMSociety](https://github.com/OMSociety/Omnimo) 维护。
