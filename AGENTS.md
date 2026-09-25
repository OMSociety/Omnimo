# Omnimo（DSH 侧 fork）改造指南

面向接手本仓库的人或 AI。先读本文再动手。
标注**（实测）**的结论都在本仓库实机验证过；标注**（推论）**的只有结构依据，动手前请自行确认。

## 1. 项目是什么，边界在哪

| 项 | 值（实测） |
|---|---|
| 本地路径 | `D:\WorkSpace\Omnimo` |
| `origin` / `upstream` | `OMSociety/Omnimo` / `fediaFedia/Omnimo` |
| 分支 / HEAD | `master`（唯一分支）/ `git log -1 --oneline；工作区状态与未决项见 §10 
| 用户桌面 | `Skins\WP7` 是指向本仓库 `WP7\` 的目录联接（junction） |

本 fork **只做四件小事**：① 设置面板、保存面板中文化（界面中文，磁贴表面英文）；② 日程同步、待办同步（只做公开 ICS 订阅，见 §5 第 4 条）；③ 修既有 bug；④ 一点微小的工作。

**明确不做**：重画视觉；复刻全部面板（实测 `WP7\Panels\` 下 62 个面板目录）；自建公共控件层；改设计语言；换字体。

## 2. 目录解剖

| 路径 | 作用 | 实测要点 |
|---|---|---|
| `WP7\` | 皮肤根 | 子目录 `@Resources` `Background` `Gallery` `Hubs` `Panels` `TextItems`；根下 `Launcher.ini` `LauncherDark.ini` |
| `WP7\@Resources\Common\Variables\UserVariables.inc` | 全局变量 | 纯 ASCII 无 BOM 1243 字节；含 `MainLanguage=EnglishChinese` |
| `WP7\@Resources\Common\Variables\Languages\` | 语言包 | 8 个语言 + `lang.inc`（`langcode`、`DominantRSS`）；`English.inc` 283 键 306 行 |
| `WP7\@Resources\Common\Background\Language\` | AutoIt 工具语言 | 每份 33 键 34 行，UTF-16LE+BOM |
| `WP7\@Resources\Structure\<档位>\Main.inc` | 面板档位底板 | 13 档：`Circle Double DoubleV HalfDouble HalfSingle Huge HugeV Mini miniCircle Single Square win10 win7`；提供 `[bg]` `[overlay]` `[TextStyle]` `[FullTextStyle]` `[IconStyle]` 与 `TypeW/TypeH/PaddingW/PaddingH` |
| `WP7\@Resources\Config\Panels\<Name>\` | 每面板配置 | 85 个目录，各含 `UserVariables.inc` + `RainConfigure.cfg` |
| `WP7\Gallery\` | 设置界面 | `main.ini`、`scroll.inc`（运行时状态）、`panels.inc`、`cat1.inc`…`cat7.inc`（分类登记表，`cat1.inc` 73 段）、`Settings\settings.ini`+`settingsall.ini` |
| `WP7\Panels\` | 面板本体 | 62 个目录，**一档一个文件**（如 `RAM\Item.ini`…`Item4.ini`） |
| `AutoIT\` | 配置工具源码 | 10 个 `.au3`（`Config.au3` `ConfigBackground.au3` `PanelCreator.au3`…）+ `build.bat` + `Language\*.cfg` + `Includes\` |
| `LICENSE` / `THIRD-PARTY.md` | 许可 | GPL-2.0 全文；第三方声明 195 行 8 节 + 附录 |

## 3. 编码与行尾陷阱（最容易翻车）

**实测分布**（`WP7\` 下 `.ini/.inc/.cfg` 共 1571 个）：纯 ASCII 的 utf-8 1447；UTF-16LE+BOM 91；cp1252 20；cp936 7；含非 ASCII 的 utf-8 4；UTF-8+BOM 2。
**行尾**：纯 CRLF 1543；混合 CRLF+裸 LF 15；纯裸 LF 4；纯裸 CR 1。

| 抽检文件 | 编码 | 行尾 |
|---|---|---|
| `WP7\Gallery\main.ini` | UTF-16LE+BOM | **裸 CR × 225**（另有 1 个 CRLF） |
| `WP7\Panels\Network\Item.ini` | UTF-16LE+BOM | 混合：CRLF 59 + 裸 LF 164 |
| `WP7\Gallery\cat7.inc` | UTF-16LE+BOM | 纯 CRLF |
| `WP7\@Resources\Common\Variables\Languages\EnglishChinese.inc` | UTF-16LE+BOM | 纯 CRLF |
| `WP7\@Resources\Common\Background\Language\Chinese.cfg` | UTF-16LE+BOM | 纯 CRLF |
| `WP7\@Resources\Common\Variables\UserVariables.inc` | 纯 ASCII | 纯 CRLF |
| `WP7\@Resources\Structure\Huge\Main.inc` | 纯 ASCII | 纯 CRLF |

**规则**

1. `read` / `edit` / `write` 工具只处理 UTF-8。改皮肤文件**必须**用能保留编码与行尾的 Python 补丁脚本：二进制读入 → 按嗅探到的编码解码 → 替换 → 按**同一编码**写回，写文件时带 `newline=""` 以免 Python 再做换行转换。
2. Windows 控制台是 GBK，Python `print` 中文会抛 `UnicodeEncodeError`；把结果写进 UTF-8 文件再用 `Get-Content -Encoding utf8` 读。
3. 编码嗅探顺序：`UTF-16LE+BOM` → `UTF-8+BOM` → 无 BOM 时试 `utf-8` → `cp936` → `cp1252`。注意**纯 ASCII 文件会同时通过多种编码**（实测 `UserVariables.inc`、`color.inc` 都是纯 ASCII），会误判成 utf-8；要另判"是否含 ≥0x80 的字节"。
4. 行尾别用 `$` 锚定的正则（CRLF 下会在 `\n` 前匹配并留下 `\r`，裸 CR 文件更糟），改用 `(?=\r|\n|$)`。PowerShell 里 `,` 比 `+` 绑得紧，数组字面量要加括号；引号转义易错，复杂替换一律写成 `.py` 脚本。
5. 本 fork 新增的 `Panels\Agenda\*` 与 `Config\Panels\Agenda\*` 是**无 BOM UTF-8**（与皮肤里大量 UTF-16 不同）；新增文件沿用此约定，改老文件则必须保原编码。

## 4. i18n 架构

链路（实测）：`Common\Variables\UserVariables.inc` 定义 `MainLanguage` → 各配置用
`@include1=#@#Common\Variables\Languages\#MainLanguage#.inc` 引入（**538 个 `.ini` 这么写**）。
Rainmeter 变量**后写者胜**，include 顺序即优先级。

面板 include 顺序（实测 `WP7\Panels\Network\Item.ini`）：

```
@include  = #@#Common\Variables\UserVariables.inc             ; 全局变量
@include1 = #@#Common\Variables\Languages\#MainLanguage#.inc  ; 语言包
@include2 = #@#Common\color\color.inc                         ; 主题色
@include3 = #@#Config\Panels\Network\UserVariables.inc        ; 本面板用户参数
@include4 = #@#Structure\#PanelType#\Main.inc                 ; 档位底板
```

`Gallery\main.ini` 顺序：`UserVariables` → `Languages` → `color` → `Common\Gallery\Color\Modern\<Dark|Light>\tt.inc` → `scroll.inc` → `panels.inc` → `<LastCat>.inc`（登记表）。

**本项目新增**

| 文件 | 内容 |
|---|---|
| `WP7\@Resources\Common\Variables\Languages\EnglishChinese.inc` | 283 键 306 行（与 `English.inc` 键数行数一致，UTF-16LE+BOM）；界面/菜单中文、磁贴表面英文，已是默认 `MainLanguage` |
| `WP7\@Resources\Common\Background\Language\Chinese.cfg` | 33 键，与同目录 `English.cfg` 键名同序（实测完全一致） |
| `AutoIT\Language\Chinese.cfg` | 源码侧副本 33 键（比同目录 `English.cfg` 的 31 键多 `Apply`、`Reset`） |

**界面键与表面键的划界规则**（生成 `EnglishChinese.inc` 时采用）：

```
翻成中文的键 = (设置界面用到的键 ∪ 右键菜单用到的键) − (磁贴表面可见 Text= 用到的键)
```

判"可见"要跳过整段 `Hidden=1` 的表（`Hidden=` 常写在 `Text=` 之后，须整段读完再判）。

**刻意保持英文的 7 个键**：`Folders` `weather` `Humidity` `Pressure` `Wind` `brightness` `start`。它们确实显示在磁贴表面，而表面按英文宽度排版；这 7 个都不出现在右键菜单里，所以菜单仍可全中文。

面板库里的面板名来自 `tt.inc` 的 `Text=#CURRENTSECTION#`，即**目录名本身**而非语言键。（推论：要本地化面板名需在登记表覆盖 `Text=` 或改 `tt.inc`。）

## 5. Rainmeter 机制坑（必须知道，均有实测依据）

| # | 坑 | 现象 | 正解 |
|---|---|---|---|
| 1 | `@include`/`@include1..N` 按数字升序生效 | 后写覆盖先写 | 要生效的覆盖放在编号更大的 include 里 |
| 2 | 变量名**不区分大小写** | `TextItems` 与 `textitems` 是同一变量，互相覆盖 | 改一个键要改掉所有拼写（按小写比对） |
| 3 | Lua 里 **`0` 是真值** | `if compact then` 对 `compact=0` 也成立 | 必须显式比较：`if compact == 1 then` |
| 4 | `MeasureWebParser` 底层 `InternetOpenUrl`，**只能 GET** | 需 PROPFIND 的 iCloud 私密 CalDAV 做不了 | 只做公开 ICS 订阅；`webcal://` 要在面板里改写成 `https://` |
| 5 | WebParser 取正文 | `Download=1` 时字符串值变成下载文件路径（实测仅 58~64 字符） | 用 `RegExp=(?s)^(.*)$` + `StringIndex=1` |
| 6 | Container 语义 | 被指定为 Container 的表**自身不绘制**（拿 `[bg]` 当遮罩 → 磁贴背景消失）；它是**按像素做 alpha 蒙版**（遮罩 alpha≈0 → 内容全被蒙掉） | 裁剪要**另建不透明的独立遮罩表**再 `Container=` 指向它 |
| 7 | 档位几何来自 `Structure\<档位>\Main.inc` | 尺寸算错会露出边界 | `Height=150` 为基准单位，`#Height#*TypeW/TypeH`；`+10` **只加在长边**（`double` 只加宽、`doubleV` 只加高） |
| 8 | 面板在 Gallery 里是 `cat1..cat7.inc` 中一个**与面板目录同名**的表 | 不登记就不出现在面板库 | 见 §6 第 6 步；`[EssentialPanel]` 样式定义在 `@Resources\Common\Gallery\Color\Modern\<Dark\|Light>\tt.inc`，动作为 `!ToggleConfig "WP7\Panels\#CURRENTSECTION#" "Item.ini"` |
| 9 | 档位名大小写混用（`single`/`HalfDouble`/`DoubleV` 并存） | Windows 上都能用 | 靠文件系统不区分大小写。（推论：跨平台会踩，新写统一小写更稳） |
| 10 | 新建的皮肤目录 | 启动后新目录不被发现 | 先 `!RefreshApp`，再 `!ActivateConfig` |

## 6. 新增一个面板的标准流程

1. 建 `WP7\Panels\<Name>\`，**一档一个文件**（`Item.ini`、`Item2.ini`…）。每个文件 `[Variables]` 至少要有 `Height=150` 与 `PanelType=<档位>`（取 `Structure\` 下的目录名）。
   > **注意：** `WP7\@Resources\Config\Panels\<Name>\UserVariables.inc` 是被 include 进来的文件，**第一行必须是 `[Variables]`**。缺段头时其中的键不属于任何段、会被静默忽略——症状是面板里 `#Feed1#` 这类变量解析不出来，而日志不报 include 错，只有下游异常（实测：WebParser 报 `ErrorCode=12006 URL 未使用可识别的协议`，诊断表原样打出 `#Feed1#`）。这是本项目踩过的最隐蔽的一坑。
2. 头部骨架照抄现有面板（实测 `Panels\Agenda\Item.ini`、`Panels\Network\Item.ini`）：`Group=Panel`、`DragGroup=WP7Panel`、`Author=`、`MouseActionCursor=0`、`MiddleMouseUpAction=!DeactivateConfig`、`Blur=#globalblurenable#`、`BlurRegion=#blurtype#,(5-#Padding#),(5-#Padding#),<卡片宽>,#blurcornerradius#`（宽高按 §5 第 7 条算）。
3. include 顺序照 §4 的五行写法。
4. 右键菜单固定写法：

```
RightMouseUpAction=[!SkinCustomMenu]
ContextTitle=#Settings#
ContextAction=["#@#Common\Config\config.exe" #PanelType# "#CURRENTCONFIG#" "#CURRENTFILE#" "#SETTINGSPATH#" "#SKINSPATH#"]
ContextTitle2=#Refresh#
ContextAction2=[!Refresh #CurrentConfig#]
```

分隔线用 `ContextTitleN=----`。菜单文字取语言包键（`#Settings#` `#Refresh#` `#Close#` `#Alternative#`…），因此随 `MainLanguage` 自动切换。

5. 用户参数与设置界面：`WP7\@Resources\Config\Panels\<Name>\UserVariables.inc` 放默认值；同目录 `RainConfigure.cfg` 按 **4 行一组**（参数名 / 界面标题 / 控件类型 / 控件参数，如 `Text`、`Checkbox:0:1:Show`），文件尾 `[Options]` + `Colorizable=1`。实测参照 `Config\Panels\Agenda\RainConfigure.cfg` 与 `Config\Panels\Network\RainConfigure.cfg`。
6. 在对应登记表（`WP7\Gallery\cat1.inc`…`cat7.inc`）加**与目录同名的表**：

```
[<Name>]
Meter=String
MeterStyle=EssentialPanel
Group=Cat1 | Bye
```

7. 许可：面板 ini 的 `License=` 统一写 `Creative Commons Attribution-Noncommercial-Share Alike 3.0 License`（与 `THIRD-PARTY.md` 的分层一致）。

## 7. 验证方法（靠实测，不靠推断）

1. **先备份** `%APPDATA%\Rainmeter\Rainmeter.ini`，在 `[Rainmeter]` 段置 `Logging=1`，刷新后读 `%APPDATA%\Rainmeter\Rainmeter.log` 抓 `ERRO` 与 Lua 报错；收尾时还原 ini 并逐字节比对。
2. 激活：`Rainmeter.exe "!RefreshApp"` → 等约 9 秒 → `Rainmeter.exe "!ActivateConfig" "WP7\Panels\<Name>" "Item.ini"`。
3. 取窗口：类名 `RainmeterMeterWindow`，标题含配置路径；`GetWindowRect` 定位后 `CopyFromScreen` 截图，进程需 DPI 感知（`SetThreadDpiAwarenessContext(-4)`）。
4. **截图前必须把光标移离面板**：底板 `[bg]` 的 `MouseOverAction` 会改卡片 tint，像素/哈希比对会出假阳性（实测）。（推论：更稳的判据是读出变量值，或只比对面板内部区域。）
5. 收尾：`!DeactivateConfig`；`git checkout -- WP7\Gallery\scroll.inc`（运行时状态，见 §8）。

## 8. 凭据与隐私纪律

日历订阅链接（`https://…/published/2/…`）**本身就是凭据**：拿到链接的任何人都能读那份日历。

1. **绝不写进仓库、脚本或文档**。测试时以命令行参数传入，落点只能是本地忽略目录；测完重新生成并全文检索确认干净。
2. 仓库里带的默认订阅必须是公开源（实测可用：`https://www.officeholidays.com/ics/china`、`…/south-korea`、`…/hong-kong`）。Apple 的 `calendars.icloud.com` 是 gzip 传输，Python 直取会拿到二进制（实测），不适合做默认。
3. `.git/info/exclude` 实际内容（本机生效，不入库）：

```
WP7/@Resources/**/UserVariables.inc
WP7/@Resources/**/Varrar.inc
WP7/@Resources/Common/hue.ini
WP7/@Resources/Common/Color/color.inc
WP7/@Resources/Common/Weather/WeatherComVariables.inc
WP7/@Resources/Common/Weather/WeatherComJSONVariables.inc
WP7/@Resources/Common/PanelCreator/Resources/Colors.inc
WP7/Gallery/MultiManager/Saved/
WP7/Gallery/main.ini
WP7/Gallery/scroll.inc
WP7/Gallery/Intro/save.inc
```

4. **exclude 只对未跟踪文件生效**：已跟踪文件照旧出现在 `git status`，也不会被 `git add` 捕获。改它们的默认值必须 `git add -f`。已这样提交过两例：`WP7/@Resources/Common/Variables/UserVariables.inc`、`WP7/@Resources/Config/Panels/Network/UserVariables.inc`。
   已知"已跟踪但被 exclude 匹配"的还有：`Common/Background/Varrar.inc`、`Common/Color/color.inc`、`Common/Settings/UserVariables.inc`、`Common/MultiManager/Varrar.inc`、`Config/**/UserVariables.inc` 等。注意 `Config\Panels\Agenda\UserVariables.inc` 也被匹配，提交它同样要 `-f`。
5. `WP7\Gallery\scroll.inc` 是运行时状态（`LastCat`）；提交前 `git checkout --` 还原，别把当时打开的页签带进提交。

## 9. 提交与发版规范

1. commit message 用**英文**，说清 **Why**，不罗列 What；一个提交只做一件事。
2. 改动面用 `git diff --name-status upstream/master -- .` 核对，别把 §8 的运行时文件带进去。
3. 对外文档**零 emoji**：表格与标题写纯文本，提示块用 `> **注意：**`；代码块里程序真实输出的字面量逐字保留。
4. 许可分层：软件 **GPL-2.0**（`LICENSE`），图像/媒体 **CC BY-NC-SA 3.0**（各面板 ini 的 `License=`）；逐文件声明优先，细节与未决项见 `THIRD-PARTY.md`。发版打 `vX.Y.Z` tag。

## 10. 当前状态与已知未决项

**相对 `upstream/master`（实测）：新增 13 / 修改 22 / 删除 0**（`git diff --name-status upstream/master -- .`）

已发布 **v0.1.0**（annotated tag + GitHub Release）。仓库**工作区干净**，无未提交项。

| 类别 | 内容 |
|---|---|
| 新增 | `LICENSE`、`THIRD-PARTY.md`、`AGENTS.md`、`CHANGELOG.md`、两份 `Chinese.cfg`（皮肤侧 + AutoIt 源码侧）、`EnglishChinese.inc`、`Panels\Agenda\`（`Item/Item2/Item3.ini` + `agenda.lua`）、`Config\Panels\Agenda\`（`UserVariables.inc` + `RainConfigure.cfg`） |
| 修改 | 15 个面板文件（缺陷修复）、`Gallery\cat7.inc`（语言列表的「简体中文」取代 `[Help Translate]`）、`Gallery\cat1.inc`（登记 Agenda）、`Gallery\Intro\intro.ini`（向导按钮）、全局 `UserVariables.inc`（`MainLanguage=EnglishChinese`）、`Config\Panels\Network\UserVariables.inc`（默认 ping 改字面 IP）、`readme.md`（fork 说明） |

已完成的验证（均为实机）：设置界面 7 页中文无溢出；语言列表出现「简体中文」；面板右键菜单全中文；Agenda 面板在面板库可见并可用、滚轮滚动生效、卡片裁剪正确、订阅抓取成功（日志无 12006）；网络面板显示真实延迟；被修表达式在日志中的报错消失。

未决项：

| # | 项 | 现状 |
|---|---|---|
| 1 | 待办同步 | 未开始 |
| 2 | 静置回顶的干净验证 | 功能已实现；此前的像素/哈希比对受底板 `MouseOver` 染色干扰（见 §7 第 4 条），尚未用干净判据复核 |
| 3 | Agenda 磁贴图标 | 面板库中的磁贴显示兜底图形；图标映射机制未查清（已排除：无按面板名命名的 PNG、`Gallery\hex.lua` 仅 7 行且与图标无关、`[EssentialPanel]` 样式无 `ImageName`） |
| 4 | AutoIt 工具默认语言 | 保持英文（运行时值），需用户在设置界面选一次「简体中文」 |
| 5 | 7 个表面键保持英文 | 见 §4；设置界面中对应 7 格也随之显示英文 |
| 6 | 6 个 Microsoft Segoe 字体 | 未获再分发授权（`THIRD-PARTY.md` 第 8 节第 4 条） |
| 7 | 面板名本地化 | 面板库里的名字来自目录名（`Text=#CURRENTSECTION#`），未本地化 |
