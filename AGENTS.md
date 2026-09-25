# Omnimo（DSH 侧 fork）改造手册

Omnimo 是 Rainmeter 桌面皮肤（磁贴式面板集合）；本仓库是它的 DSH 侧 fork，保留上游设计与面板集。本文面向下一个接手的人或 AI；动手前先读 §1 的边界与 §10 的未决项。标注**（实测）**的结论已在本仓库验证；标注**（推论）**的只有结构依据，动手前自行确认。

## 1. 项目定位与边界

| 项 | 值（实测） |
|---|---|
| 本地路径 | `D:\WorkSpace\Omnimo` |
| `origin` / `upstream` | `OMSociety/Omnimo` / `fediaFedia/Omnimo` |
| 分支 / 已发布 | `master`（唯一分支）；annotated tag `v0.1.1`、`v1.1.0` + 同名 GitHub Release |
| 桌面映射 | `C:\Users\<用户>\Documents\Rainmeter\Skins\WP7` 是指向本仓库 `WP7\` 的目录联接（junction） |

**只做四件小事**：① 设置面板 / 保存面板中文化（界面中文，磁贴表面英文）；② 日程同步（只做公开 ICS 订阅，见 §5 第 4 条）；③ 修既有 bug；④ 一点微小的工作。
**待办同步已由用户决定不做**（不要再实现）。

**明确不做**：重画视觉；复刻全部面板（`WP7\Panels\` 现有 62 个面板目录）；自建公共控件层；改设计语言；换字体。

## 2. 目录解剖与关键文件职责

| 路径 | 作用 | 实测要点 |
|---|---|---|
| `WP7\` | 皮肤根 | 子目录 `@Resources` `Background` `Gallery` `Hubs` `Panels` `TextItems`；根下 `Launcher.ini` `LauncherDark.ini` |
| `WP7\@Resources\Common\Variables\UserVariables.inc` | 全局变量 | ANSI(cp1252)、无 BOM、1246 字节、纯 CRLF；含 `MainLanguage=EnglishChinese`；`SubstituteFeed` 尾部三个替换目标是 cp1252 单字节字符（`ä`=0xE4、`ö`=0xF6、`–`=0x96），故本文件不是纯 ASCII |
| `WP7\@Resources\Common\Variables\Languages\` | 语言包 | 8 个语言（`English` `EnglishChinese` `German` `Spanish` `Russian` `Dutch` `French` `Portuguese`）+ `lang.inc`（`langcode`、`DominantRSS`） |
| `WP7\@Resources\Common\Color\color.inc` | 当前主题色 | 纯 ASCII、纯 CRLF；被 523 个配置 include（在语言包之后，故覆盖语言包同名键）。**全库唯一定义 `Padding`/`Opacity`/`Opacity2`/`Globalblurenable`/`Xposition` 的文件**，卡片尺寸由 `Padding` 决定（见 §5 第 15 条） |
| `WP7\@Resources\Common\Background\Language\` | AutoIt 工具语言 | 每份 33 键 34 行，UTF-16LE+BOM |
| `WP7\@Resources\Structure\<档位>\Main.inc` | 面板档位底板 | **13 档**：`Circle Double DoubleV HalfDouble HalfSingle Huge HugeV Mini miniCircle Single Square win10 win7`；提供 `[bg]` `[overlay]` `[TextStyle]` `[FullTextStyle]` `[IconStyle]` 与 `TypeW/TypeH/PaddingW/PaddingH` |
| `WP7\@Resources\Config\Panels\<Name>\` | 每面板配置 | **85 个目录**，各含 `UserVariables.inc`（用户参数）+ `RainConfigure.cfg`（设置界面 schema） |
| `WP7\Gallery\` | 设置界面（面板库） | `main.ini`、`scroll.inc`（运行时状态）、`panels.inc`（自定义面板清单）、`cat1.inc`…`cat7.inc`（分类登记表）、`Settings\`；5 个子目录 |
| `WP7\Panels\` | 面板本体 | **62 个目录**，**一档一个文件**（如 `RAM\Item.ini`…`Item4.ini`） |
| `WP7\@Resources\Graphics\Gallery\mask-*.png` | 面板库图标层 | 4 张：`mask-essential` `mask-shortcut` `mask-textitems` `mask-contrib`，与分类表一一对应 |
| `AutoIT\` | 配置工具源码 | 9 个 `.au3`（`Config.au3` `ConfigBackground.au3` `PanelCreator.au3`…）+ `build.bat` + `Language\*.cfg` + `Includes\` |

**面板库的三个样式**（定义在 `@Resources\Common\Gallery\Color\Modern\<Dark|Light>\tt.inc`）：`[EssentialPanel]`（常用面板磁贴，`tt.inc:232`）、`[EssentialPanelText]`（`tt.inc:252`）、`[EssentialPanelBlank]`（自定义面板格子，`tt.inc:268`）。
`[EssentialPanel]` 的动作是 `!ToggleConfig "WP7\Panels\#CURRENTSECTION#" "Item.ini"`，即**磁贴表名 = 面板目录名**（实测）。

## 3. 编码与行尾（最容易翻车）

**实测分布**（`WP7\` 下 `.ini/.inc/.cfg` 共 1562 个）：ASCII 1436；UTF-16LE+BOM 92；ANSI(cp1252) 28；UTF-8 无 BOM 4；UTF-8+BOM 2。
**行尾**：纯 CRLF 1533；混合 16；单行无换行 9；纯裸 LF 4（均为 UTF-16 的上游文件）。
**口径**：以上两个分布都是**检出层**（本机 `core.autocrlf=true`）的量；存储层除被 git 判为二进制的文件外全是 LF。`.lua` 不在 `.gitattributes` 覆盖内（该文件只给 `*.ini`/`*.inc` 配了 diff 驱动），所以 `agenda.lua` 在工作树里就是纯裸 LF。

| 抽检文件 | 编码 | 行尾 |
|---|---|---|
| `WP7\Gallery\main.ini` | UTF-16LE+BOM（9976 字节） | **裸 CR × 224 + CRLF × 2** |
| `WP7\Panels\Network\Item.ini` | UTF-16LE+BOM | 混合：CRLF 59 + 裸 LF 164 |
| `WP7\Gallery\cat7.inc` | UTF-16LE+BOM | 纯 CRLF |
| `WP7\@Resources\Common\Variables\Languages\EnglishChinese.inc` | UTF-16LE+BOM | 纯 CRLF |
| `WP7\Gallery\cat1.inc` / `Panels\Volume\Item.ini` | **纯 ASCII** | 纯 CRLF |
| `WP7\Panels\Agenda\Item.ini` | UTF-8 无 BOM | 纯 CRLF |
| `WP7\Panels\Agenda\agenda.lua` | UTF-8 无 BOM | 纯裸 LF |
| `WP7\@Resources\Config\Panels\Agenda\RainConfigure.cfg` | UTF-16LE+BOM | 纯 CRLF |

1. `read` / `edit` / `write` 工具只处理 UTF-8。改皮肤文件**必须**用 Python 补丁脚本：二进制读入 → 按嗅探到的编码解码 → 替换 → 按**同一编码**写回，且写文件时带 `newline=""`；否则 Python 会把 `\r\n` 写成 `\r\r\n`（实测过）。
2. 控制台是 GBK，`print` 中文会抛 `UnicodeEncodeError`；把结果写进 UTF-8 文件再 `Get-Content -Encoding utf8` 读，或只打印 ASCII。
3. 嗅探顺序：`UTF-16LE+BOM` → `UTF-8+BOM` → 无 BOM 时试 `utf-8` → `cp936` → `cp1252`。**纯 ASCII 文件会同时通过多种编码**（实测 `UserVariables.inc`、`color.inc`、`cat1.inc`、`Volume\Item.ini`），要另判"是否含 ≥0x80 字节"。
4. 行尾别用 `$` 锚定的正则（CRLF 下会留下 `\r`，裸 CR 文件更糟），改用 `(?=\r|\n|$)`；用整行匹配时记住行尾可能带 `\r`。
5. PowerShell 里 `,` 比 `+` 绑得紧（数组字面量要加括号）、反引号是转义符（写 Markdown 反引号会被吃掉）、`|` 在双引号内仍是管道；**复杂替换一律写成 `.py` 文件**，别用 `python -c`。

## 4. i18n 架构

链路（实测）：`Common\Variables\UserVariables.inc` 定义 `MainLanguage` → 各配置用
`@include1=#@#Common\Variables\Languages\#MainLanguage#.inc` 引入（538 个 `.ini` 这么写）。
Rainmeter 变量**后写者胜**，include 编号顺序即优先级。

面板的 include 五连（实测 `WP7\Panels\Network\Item.ini`，Agenda 同构）：

```
@include  = #@#Common\Variables\UserVariables.inc             ; 全局变量
@include1 = #@#Common\Variables\Languages\#MainLanguage#.inc  ; 语言包
@include2 = #@#Common\color\color.inc                         ; 主题色
@include3 = #@#Config\Panels\<Name>\UserVariables.inc         ; 本面板用户参数
@include4 = #@#Structure\#PanelType#\Main.inc                 ; 档位底板
```

`Gallery\main.ini`：`UserVariables` → `Languages` → `color` → `Common\Gallery\Color\Modern\<Dark|Light>\tt.inc` → `scroll.inc` → `panels.inc` → `<LastCat>.inc`。

**本 fork 的中文资产**

| 文件 | 内容 |
|---|---|
| `Languages\EnglishChinese.inc` | **284 键**（与 `English.inc` 键数一致、行序一致），UTF-16LE+BOM；界面/菜单中文、磁贴表面英文；已是默认 `MainLanguage` |
| `Common\Background\Language\Chinese.cfg` | 33 键，与同目录 `English.cfg`（33 键）键名同序 |
| `AutoIT\Language\Chinese.cfg` | 33 键（同目录 `English.cfg` 31 键，实测源码侧多 `Apply`、`Reset`） |
| 8 份语言包的 `PanelAgenda` 键 | 中文包＝`日程`，其余＝`Agenda`（用于面板名本地化） |

**界面键与磁贴表面键的划界规则**（生成 `EnglishChinese.inc` 的依据）：

```
翻成中文的键 = (设置界面用到的键 ∪ 右键菜单用到的键) − (磁贴表面可见 Text= 用到的键)
```

判"可见"要跳过整段 `Hidden=1` 的表（`Hidden=` 常写在 `Text=` 之后，须整段读完再判）。**刻意保持英文的 7 个键**：`Folders` `weather` `Humidity` `Pressure` `Wind` `brightness` `start`——它们出现在磁贴表面，而表面按英文宽度排版；这 7 个都不在右键菜单里，所以菜单仍可全中文。

**面板名本地化**：面板库磁贴默认取 `Text=#CURRENTSECTION#`（即目录名，英文）。要本地化就在登记表里覆盖：`[Agenda]` 加 `Text="#PanelAgenda#"` 与 `ToolTipText=#PanelAgenda#`（实测生效，中文界面显示「日程」）。

## 5. Rainmeter 机制坑（每条都有实测依据）

| # | 坑 | 现象 | 正解 |
|---|---|---|---|
| 1 | `@include`/`@include1..N` 按数字升序生效 | 后写覆盖先写 | 要让某个覆盖生效，就把它放在编号更大的 include 里 |
| 2 | 变量名**不区分大小写** | `TextItems` 与 `textitems` 是同一个变量 | 改一个键要改掉所有拼写（按小写比对） |
| 3 | Lua 里 **`0` 是真值** | `if compact then` 对 `compact=0` 也成立 | 显式比较：`if compact == 1 then` |
| 4 | `MeasureWebParser` 底层 `InternetOpenUrl`，**只能 GET** | 需 PROPFIND 的 iCloud 私密 CalDAV 做不了 | 只做公开 ICS 订阅；面板里把 `webcal://` 改写成 `https://` |
| 5 | WebParser 取正文 | `Download=1` 时字符串值是**下载文件路径**（实测仅 58~64 字符） | 用 `RegExp=(?s)^(.*)$` + `StringIndex=1` |
| 6 | Container 语义 | 被指定为 Container 的表**自身不绘制**（拿 `[bg]` 当遮罩 → 磁贴背景消失）；它是**按像素做 alpha 蒙版**（遮罩 alpha≈0 → 内容全被蒙掉） | 裁剪要**另建不透明的独立遮罩表**再 `Container=` 指向它（Agenda 的 `[Clip]` 即此法） |
| 7 | 档位几何来自 `Structure\<档位>\Main.inc` | 尺寸算错会露出边界 | `Height=150` 为基准单位，`#Height#*TypeW/TypeH`；那个 `+10` **只加在长边**（`double` 只加宽、`doubleV` 只加高） |
| 8 | **被 include 的配置 inc 必须自带 `[Variables]` 段头** | 缺段头时其中的键不属于任何段、被**静默忽略**；日志不报 include 错，只有下游异常（实测：WebParser 报 `ErrorCode=12006 URL 未使用可识别的协议`，诊断表原样打出 `#Feed1#`） | `Config\Panels\<Name>\UserVariables.inc` **第一行写 `[Variables]`** |
| 9 | **`RainConfigure.cfg` 的格式是死的** | 4 行一组：参数名 / 界面标题 / 控件类型 / **空行**；`Config.au3:162-188` 读第 4 行，非空且不是 `[Options]` 就弹「Unable to read RainConfigure.cfg」 | 每组后面**必须留空行**；尾段 `[Options]` + `Colorizable=1`（`$Colorizable` 取 `[Options]` 下一行最后一个字符）；编码用 UTF-16LE+BOM |
| 10 | 滚轮的正规接法 | 面板滚不动 | 在 `[Rainmeter]` 段写 `MouseScrollUpAction=` / `MouseScrollDownAction=`（范例 `Panels\Volume\Item.ini:12-13`）。另注：**面板库自身也带滚轮动作**（`Gallery\cat1.inc:23/24/34`）且窗口几乎占满屏幕，面板库开着时滚轮会被它吃掉 |
| 11 | `Rainmeter.ini` 记的是哪一档 | 多文件面板重开时档位不对 | `Active = 文件序号 + 1`（源码 `Library\Rainmeter.cpp:1157-1159`：`ActivateSkin(*iter, skinFolder.active - 1)`）；配置段的 `WindowX`/`WindowY` 是窗口屏幕坐标（源码 `Library\Skin.cpp:2243-2244`） |
| 12 | 面板库常用面板那排是**两层**的 | 插/删一格磁贴，后面的图标全错位 | 磁贴是 `catN.inc` 手写的 String 表；图标是 `mask-<类>.png` 里**按格烤好的 2 倍图**，由 `[Cat1Mask]` 类表 + `imagetint=#textcolor2#` 绘制。**增删/移动磁贴必须同时改两处**，几何见 §6 路线 A 第 6 步 |
| 13 | 往磁贴之间插辅助表 | 其后所有区块的标签整体偏移 | 相对定位（`Y=...R`/`X=...r`）只看**文件里上一个表**。辅助表要放**文件末尾**并用 `[表名:X]`/`[表名:Y]` 绝对定位 |
| 14 | 新建的皮肤目录 | 启动后新目录不被发现 | 先 `!RefreshApp`，再 `!ActivateConfig` |
| 15 | **每套主题自带 `Padding`，它决定所有卡片的尺寸** | 换版本或换主题后，所有面板看起来「缩了一圈」 | 卡片宽度公式是 `(#Height#+(#Padding#*2))*#ScaleDpi#`，而 `Padding` **只由主题文件** `@Resources\Common\Color\*.inc` 定义（`Structure\*\Main.inc` 与 85 个面板配置里都是 0 处，实测），所以它直接生效、不会被覆盖。master 的 33 套主题取 0（少数取 3 或 4），而 Omnimo 10 Lite 里用户桌面用的那套取 5 —— 差 10 逻辑像素，且卡片还内缩 5px（`X=(5-#Padding#)`）。本仓库已把该文件的当前值提交为默认（`Padding=5`、`Opacity=50`、`Opacity2=240`、`Globalblurenable=0`、`Xposition=10`）；注意**在面板库换主题会把 `Padding` 改回那套主题自带的值**（master 的主题多为 0，少数 3/4） |
| 16 | **`RainConfigure.cfg` 的 `Checkbox:a:b` 是「未勾选写 a、勾选写 b」** | 把 `Checkbox:1:0` 读成"勾选=1"会把 `Hidden=#X#` 的语义判反（本仓库因此误"修"过 DigitalClock 两处） | 源码 `Config.au3`：`StringSplit` 后 `VarOpts[2]=a`、`VarOpts[3]=b`；写盘 `_WriteOption` 勾选取 `VarOpts[3]`、未勾选取 `VarOpts[2]`（实测行 458），显示态 `$value == VarOpts[3]` 即勾选（行 507）。推论：`Checkbox:1:0` 的变量**勾选启用时值为 0**，`Hidden=#X#` 恰好是"启用即显示"；判断 `Update=#X#1000` 这类拼接也要按真实取值展开（`0`→`01000`→十进制 1000，Rainmeter 源码 `wcstol(…, 10)`，前导零不是八进制） |

## 6. 新增一个面板的标准流程

**路线 A：进「常用面板」那排（改视觉才走这条：手写磁贴 + 图标层）**

1. 建 `WP7\Panels\<Name>\`，**一档一个文件**（`Item.ini` `Item2.ini` `Item3.ini`…）。每个文件 `[Variables]` 至少要有 `Height=150` 与 `PanelType=<档位>`；档位名取 `Structure\` 下的目录名（上游大小写混用：`Single`/`single`、`DoubleV`/`doubleV` 并存，Windows 上都能用，新写统一小写更稳——**（推论）**跨平台会踩）。
2. 头部骨架照抄 `Panels\Agenda\Item.ini` 或 `Panels\Network\Item.ini`：`DragGroup=WP7Panel`、`Group=Panel`、`Author=`、`MouseActionCursor=0`、`MiddleMouseUpAction=!DeactivateConfig`、`Blur=#globalblurenable#`、`BlurRegion=#blurtype#,(5-#Padding#),(5-#Padding#),<卡片宽>,#blurcornerradius#`（宽高按 §5 第 7 条算），以及 §5 第 10 条的滚轮动作。
3. `[Rainmeter]` 里写标准右键菜单：`RightMouseUpAction=[!SkinCustomMenu]`，`ContextTitle/ContextAction` 成对写，分隔线用 `ContextTitleN=----`；菜单文字取语言包键（`#Settings#` `#Refresh#` `#Close#` `#Alternative#`…）因此随 `MainLanguage` 切换。`#Settings#` 的动作是
   `["#@#Common\Config\config.exe" #PanelType# "#CURRENTCONFIG#" "#CURRENTFILE#" "#SETTINGSPATH#" "#SKINSPATH#"]`。
4. include 顺序照 §4 的五连写。
5. 用户参数与设置界面：`WP7\@Resources\Config\Panels\<Name>\UserVariables.inc`（**第一行 `[Variables]`**，见 §5 第 8 条）+ 同目录 `RainConfigure.cfg`（格式见 §5 第 9 条）。
6. 在对应登记表（`WP7\Gallery\cat1.inc`…`cat7.inc`）加**与目录同名的表**，并**同时改图标层**：

```
[<Name>]
Meter=String
MeterStyle=EssentialPanel
solidcolor=#colorskin# ,215
Text="#<语言键>#"          ; 可选：本地化磁贴名
ToolTipText=#<语言键>#     ; 可选
```

   - 图标层几何（实测）：`mask-<类>.png` 是 2 倍图，**列中心 `57,178,300,421,543,664,786,907`**（格距 121.43 图内像素 = 60.92 逻辑像素，等于磁贴间距 61），**格子 = 中心 ± 60.7**；行中心按内容带实测，如 `mask-essential.png` 的时间与日期第 1/2 行 = **391 / 513**，信息第 1/2 行 = **717.5 / 838.5**。
   - 改字形请**复制它自己的字形**（例如日历取自该图 Date 那格），不要自己画。
   - **跨行回流靠"行锚点"**：默认所有磁贴横向排（`X=(61*#ScaleDpi#)r`），谁"另起一行"就看谁带 `Y=(1*#ScaleDpi#)R` + `x=(360*#ScaleDpi#)`。增删磁贴时把这组锚点交接给下一个磁贴，并同步搬移图标层字形（整段左移一格、末尾清空）。

**路线 B：进「自定义面板」（内容型面板走这条，源码 `AutoIT\PanelCreator.au3` 就是这么干的）**

1. 图标放**面板自己的目录**：`WP7\Panels\<Name>\<Name>.png`（源码第 446 行给面板配置写 `IconLocation=<Name>.png`）。
2. 在 `WP7\Gallery\panels.inc` 追加三元组（源码第 291 行 `IniWrite($PanelsInc,"Variables","Icon"&$i, $foldername&'.png')`）。`panels.inc` 现状只有 `TaskManager` 一组，序号从 2 起：

```
Name2=Example
Path2=Example
Icon2=Example.png
```

   注意 Agenda **不走这条路**：它已按路线 A 登记进 `cat1.inc` 的常用面板排，`panels.inc` 里的 Agenda 条目是早期尝试的残留，已删除（该文件与上游净 diff 为零）。
3. 前端在 `cat4.inc`（自定义面板）：`[c2] Meter=Image / MeterStyle=EssentialPanelBlank / ImageName="#ROOTCONFIGPATH#Panels\#Path2#\#Icon2#" / LeftMouseUpAction=!ToggleConfig "WP7\Panels\#Path2#" "Item.ini"`。格子通用，**增删不会错位**。
4. 删除面板时两处都要清（源码第 52-57 行：`DirRemove` 面板目录 + `IniDelete` 该条 + `!Refresh WP7\Gallery`）。

两条路线通用的许可写法：面板 ini 的 `License=` 统一写 `Creative Commons Attribution-Noncommercial-Share Alike 3.0 License`（与 `THIRD-PARTY.md` 的分层一致）。

## 7. 验证方法（靠实测，不靠推断）

1. **先备份** `%APPDATA%\Rainmeter\Rainmeter.ini`，在 `[Rainmeter]` 段置 `Logging=1`，刷新后读 `%APPDATA%\Rainmeter\Rainmeter.log` 抓 `ERRO`；收尾时还原 ini 并逐字节比对。项目本就存在的噪声：`OverlayBorder\none0.png` 缺图、`FrostedGlass.dll` 缺失（`Plugins\` 目录为空），与本 fork 的改动无关。
2. 激活：`Rainmeter.exe "!RefreshApp"` → 等约 9 秒 → `Rainmeter.exe "!ActivateConfig" "WP7\Panels\<Name>" "Item.ini"`。
3. 取窗口：类名 `RainmeterMeterWindow`，标题含配置路径；`GetWindowRect` 定位后 `CopyFromScreen` 截图（进程需 DPI 感知：`SetThreadDpiAwarenessContext(-4)`）。
4. **比对判据的两个前提**：内容加载完成（WebParser 是异步的，早拍会拍到"数据还在进入"的画面）；**把光标移离面板**（底板 `[bg]` 的 `MouseOverAction` 会改卡片 tint）。违反任一条都会得到假阳性。
5. 判据选择：验证状态量（如 `Active`）直接读变量最稳；视觉问题用图像比对，但**面板是半透明的**（透出壁纸），亚像素渲染抖动会让「逐字节相同」永远不成立——实测两张「稳定」截图仍有 0.04% 的像素差。正确做法是算**差异像素占比并给阈值**：实测滚动生效 = 14.2%，静置回顶 = 0.04%。另外，测试期间要关掉**第三方动态壁纸**（实测：动态壁纸每帧都在变，会让半透明面板的每张截图都不同；面板库里的 Slideshow 面板不是原因）。收尾：`!DeactivateConfig`；`git checkout -- WP7\Gallery\scroll.inc WP7\Gallery\main.ini`（它们会被运行时写脏）。

## 8. 凭据与隐私纪律

日历订阅链接（`https://…/published/2/…`）**本身就是凭据**：拿到链接的任何人都能读那份日历。

1. **绝不写进仓库、脚本或文档**。测试时以命令行参数传入，落点只能是本地忽略目录；测完重新生成并全文检索确认干净。自检要用**不自我匹配**的判据：`git log -p --all -- "WP7/@Resources/Config/Panels/Agenda/UserVariables.inc"` 里 `Feed1=` 的取值只应出现本条第 2 款的公开默认源；快速比对用「值长度 + sha256 前 16 位」的指纹即可。**不要**用 `git log -S'<关键词>' --all` 当这条自检：关键词会随本文档一起进提交，检索必然命中引入它的那次提交（实测命中 `8853d7bb`），自检永远失败；同理不要把任何检索字面量写进文档。
2. 仓库里带的默认订阅必须是公开源（实测可用：`https://www.officeholidays.com/ics/china`、`…/south-korea`、`…/hong-kong`）。Apple 的 `calendars.icloud.com` 是 gzip 传输，Python 直取会拿到二进制（实测），不适合做默认。
3. `.git/info/exclude` 实际内容（本机生效、不入库；`WP7/_agenda/` 是原型期的**陈旧条目**，目录已删）：

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
WP7/_agenda/
```

4. **exclude 只对未跟踪文件生效**：已跟踪文件照旧出现在 `git status`，也不受它保护。改这些文件的默认值要 `git add -f`（已这样提交过 `Common\Variables\UserVariables.inc`、`Config\Panels\Network\UserVariables.inc`）。
5. 本地已对下列文件打 **`skip-worktree`**（`git ls-files -v` 显示 `S`）：这些是**会被用户或运行时改写**的已跟踪文件，标记后既不显示为脏、也不会被误提交。撤销用 `git update-index --no-skip-worktree <路径>`。

```
WP7/@Resources/Config/Panels/Agenda/UserVariables.inc          # 用户填的私人订阅链接（凭据）
WP7/@Resources/Config/Panels/WorldClock/UserVariables.inc      # 面板会写成运行机器所在时区
WP7/Gallery/MultiManager/TimeSettings.inc                      # 布局保存的运行时状态
WP7/@Resources/Config/Panels/Slideshow/UserVariables.inc       # 用户本机的图片目录与播放参数
WP7/@Resources/Config/TextItems/MultiManager/UserVariables.inc # 各布局格的保存标记
WP7/Gallery/MultiManager/Saved/2/screenshot.png                # 布局保存时生成的缩略图
```
6. `Config\Panels\Network\UserVariables.inc`（`PingURL`）等同理：这类"用户参数文件"都是已跟踪的，改动会显示为脏，提交前逐个确认。

## 9. 提交与发版规范

1. commit message 用**英文**，说清 **Why**，不罗列 What；一个提交只做一件事。
2. 改动面用 `git diff --name-status upstream/master -- .` 核对，别把 §7 第 5 条提到的运行时文件带进去。
3. 对外文档**零 emoji**：表格与标题写纯文本，提示块用 `> **注意：**`；代码块里程序真实输出的字面量逐字保留。
4. 许可分层：软件 **GPL-2.0**（`LICENSE`），图像/媒体 **CC BY-NC-SA 3.0**（各面板 ini 的 `License=`）；逐文件声明优先，细节与未决项见 `THIRD-PARTY.md`。
5. 发版看 `CHANGELOG.md` 的体例；无 CI 的仓库发版＝**版本号 + CHANGELOG + tag + Release 一次闭口**：先把改动全部提交，再 `git tag -a vX.Y.Z -m "…"`、`git push origin master vX.Y.Z`、`gh release create vX.Y.Z --title "vX.Y.Z" -F <说明文件>`。已发布的 tag 不要移动。

## 10. 当前状态与未决项

**相对 `upstream/master`（已提交，实测）：新增 14 / 修改 35 / 删除 10**

| 类别 | 内容 |
|---|---|
| 新增 | `LICENSE`、`THIRD-PARTY.md`、`AGENTS.md`、`CHANGELOG.md`、`Languages\EnglishChinese.inc`、皮肤侧与源码侧两份 `Chinese.cfg`、`Panels\Agenda\`（`Item/Item2/Item3.ini` + `agenda.lua` + `Agenda.png`）、`Config\Panels\Agenda\`（`UserVariables.inc` + `RainConfigure.cfg`） |
| 修改 | 16 个面板文件（缺陷修复）、7 份语言包（补 `PanelAgenda` 键；第 8 份中文包是新增文件）、`Gallery\cat1.inc`（Agenda 磁贴落在时间与日期第 2 行；Corona 移除后整段回流）、`Gallery\cat7.inc`（语言列表「简体中文」取代 `[Help Translate]`）、`Gallery\Intro\intro.ini`、`Graphics\Gallery\mask-essential.png`（图标层）、`Common\Variables\UserVariables.inc`（`MainLanguage` 与 `SubstituteFeed` 编码修复）、`Config\Panels\Network\UserVariables.inc`（默认 ping 改字面 IP）、`Common\Color\color.inc`（默认主题改为桌面所依据的那套值）、`Panels\Slideshow\Item.ini` 与 `Panels\DigitalClock\Item.ini`（`Height` 对齐到桌面所依据的版本）、`AutoIT\OmnimoApp.au3` 与 `AutoIT\Config.au3`（各一处源码级缺陷修复：StringReplace 参数顺序、边框色分支读了未声明变量；只改源码，未重编译分发 exe）、`readme.md` |
| 删除 | `Panels\Corona\`、`Config\Panels\Corona\`（共 10 个文件，用户要求删；`cat1.inc` 与图标层已同步回流） |

**已实机验证**：设置界面 7 页中文且无溢出；语言列表出现「简体中文」；面板右键菜单全中文；Agenda 面板在面板库可见可加、卡片裁剪正确、订阅抓取成功（日志无 12006）、真实滚轮滚动生效（差异像素占比 14.2%）且静置回顶成立（0.04%）；网络面板显示真实延迟；桌面布置与备份逐面板对齐（含尺寸）；被修表达式在日志中的报错消失。

| # | 未决项 | 现状 |
|---|---|---|
| 1 | ~~`Panels\Agenda` 缺滚轮动作~~ | **已修复并验证**：三个 ini 的 `[Rainmeter]` 段已补 `MouseScrollUp/DownAction`（照 `Volume` 的写法）；差异像素占比判据实测 滚动 14.2% / 静置回顶 0.04% |
| 2 | ~~滚动 / 静置回顶复核~~ | **已完成**（判据见 §7 第 5 条） |
| 3 | ~~是否发新版~~ | **已发布 v0.1.1、v1.1.0**；`v0.1.0` 的 Release 与 tag 已按用户要求删除 |
| 4 | AutoIt 工具默认语言 | 保持英文（运行时值），用户需在设置界面选一次「简体中文」 |
| 5 | 7 个表面键保持英文 | 见 §4；设置界面里对应 7 格也随之显示英文 |
| 6 | 6 个 Microsoft Segoe 字体 | 未获再分发授权（`THIRD-PARTY.md` 第 8 节第 4 条） |
| 7 | 提交前要还原的运行时文件 | `WP7\Gallery\main.ini`、`scroll.inc`、`MultiManager\TimeSettings.inc`、`MultiManager\Saved\*\screenshot.png` 会被 Rainmeter 运行时改写；`git checkout --` 还原或按 §8 第 5 条标记。另：`.git/info/exclude` 里 `WP7/_agenda/` 已无对应目录，可删 |
| 8 | AutoIT 源码修了 2 处但 exe 未重编译 | `OmnimoApp.au3`（StringReplace 参数顺序）与 `Config.au3`（边框色分支读了未声明变量）已修源码；分发 exe 行为不变，重编译是独立决策（与 `config.exe` 同性质，见 `THIRD-PARTY.md` §3） |
| 9 | `EnglishChinese.inc` 约半数键未译 | 284 键中 123 个值含中文；`24HourTime`（`Settings\settings.ini:87`）、`Missing1`（`TextItems\Extra\MissingComponents\Item.ini:47`）有实测消费方，中文界面下显示英文。补哪些键是产品决策。注意 `ChangeColors`/`RefreshAll`/`SidebarColors` 全库无消费方（上游遗留死键），不算遗漏 |
| 10 | Agenda 死源提示的残余边界 | 非 ICS 响应（404/登录页）现在停在 "loading feed..."，不再误报 "no events"；要区分「还在加载」与「源已死」需加超时启发（若干轮后显示 feed unavailable），待决策 |
| 11 | `agenda.lua:280` 夏令时 | 用定长 86400 秒推窗口末日，夏令时回拨那周末一天会被少算（`buildRows` 用 `hour=12` 规避了同类问题，此处没有）；本机时区无夏令时，实际影响为零 |
| 12 | AutoIT 其余 9 项加固项 | 参数个数检查缺/错 4 处、`Execute()` 求值 ini 坐标、`DirRemove` 无路径校验 3 处、数组上限 2 处、`build.bat` 依赖 wmic、多处 CWD 相对路径——均为上游既有债或需本机权限前置，未动；明细见仓库外 `D:\WorkSpace\Omnimo-代码质量复审报告.md` |
