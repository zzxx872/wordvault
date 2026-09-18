# WordVault · 词库工作台

**把反复手打的长文本，压成 2~4 个字符的输入码。**

离线单文件网页工具，为 iOS 系统输入法的「文本替换」词库做生产、编码与多通道分发。

**中文** · [English](#english)

> 🌐 在线使用：<https://zzxx872.github.io/wordvault/>

---

## 中文说明

### 一句话概括

WordVault 帮你把「你反复手打的长内容」（地址、发票抬头、工作话术、邮箱签名…）整理成 iOS 系统输入法的**文本替换**词库，
自动生成**不冲突的拼音输入码**，并导出成不同通道需要的格式。手机浏览器打开就能用，**不需要 Mac、不需要装 App、不需要输入任何账号**。

### ⚠️ 请先读这一段：iPhone 上无法批量导入

这是整个项目最重要的前提，也是同类工具最常误导用户的地方：

> **iPhone 的「设置 › 通用 › 键盘 › 文本替换」页面里没有导入入口。** iOS 从来没有过这个功能。

批量导入 `.plist` 是 **macOS 独有**的：把文件拖进 Mac 的「系统设置 › 键盘 › 文本替换」列表，再靠 iCloud **单向**同步到 iPhone。iOS 侧只能一条一条手动新建。

系统输入法一共三层词库，只有第一层是可程序化操作的：

| 层 | 位置 | 能否程序化写入 |
|:--|:--|:--|
| ① 自定义短语 / 文本替换 | 设置 › 通用 › 键盘 › 文本替换 | iPhone 无入口；macOS 拖拽 plist；iCloud 同步 |
| ② 用户词典（自动学习词） | 键盘学习数据库 | **无任何公开 API**，只能靠日常输入让系统慢慢学 |
| ③ 第三方输入法词库 | 搜狗 / 百度 / 微信键盘 | 有导入，各家自有格式 |

因此本项目的定位**不是「一键导入」**（iOS 上不存在这件事），而是：

> **词库生产 + 输入码编码规则 + 多通道分发**

### 四条落地路径

| # | 路径 | 需要 Mac | 适合谁 |
|:-:|:--|:--:|:--|
| 1 | **网页版 → 添加到主屏幕** | 否 | 所有人。先用这个，零成本 |
| 2 | **搜狗输入法（Windows）→ 账号云同步** | 否 | 愿意改用第三方输入法，且需要真正批量写入 |
| 3 | **借一台 Mac 拖一次 plist** | 是（10 分钟） | 想留在系统输入法，追求一劳永逸 |
| 4 | **逐条录入助手** | 否 | 兜底方案。只挑 50~200 条最高频的 |

**路径 2 是唯一能完全绕开 Mac 的批量写入方式**：在 Windows 上装搜狗输入法，导入本工具导出的 `缩写,1=短语` 格式文件，登录搜狗账号同步，iPhone 装搜狗输入法（开启完全访问）+ 同一账号，词库自动下发。代价是放弃系统输入法的纯本地特性。

### 功能

- **表格编辑** — 增删改查、拖拽排序、实时搜索
- **批量粘贴导入** — 自动识别 CSV、`输入码=短语`、`输入码,短语`、Tab 分隔、Markdown 表格五种格式
- **自动生成输入码** — 内嵌 **6763 个常用汉字拼音表** + **约 160 条词组级多音字修正表**，重庆→`cq`、长沙→`cs`、银行→`yh`、朝阳→`cyq` 都正确
- **查重体检与一键修复** — 检出重复输入码、空输入码、过长短语、易误触发的短码，并给出可一键应用的建议
- **分批导出** — 按批次切分，适配逐步录入的场景
- **多格式导出** — Apple plist（`PropertyListSerialization` 兼容）/ JSON 备份 / CSV / 搜狗 `.txt` / 搜狗 iOS `.bdi`
- **逐条录入助手** — 给没有 Mac 的 iPhone 单机用户：把每条拆成「复制短语 → 粘贴 → 复制输入码 → 粘贴」，带进度条、完成标记、序号跳转、**快速模式**（只复制短语，输入码按规律手打，省一半操作）
- **PWA** — 可添加到主屏幕，Service Worker 离线缓存，断网也能用
- **纯本地** — 词条只存在浏览器 localStorage，没有任何网络请求，不采集数据

### 使用

```text
1. 打开 https://zzxx872.github.io/wordvault/  （或本地双击 docs/index.html）
2. 右上角「批量导入」，把你的长文本贴进去，选择解析格式
3. 点「一键生成输入码」，再点「一键修复问题」处理查重建议
4. 按你的落地路径导出：
   - 路径 1 / 3 → 导出 Apple plist
   - 路径 2   → 导出搜狗格式（先导 2~3 条验证格式再批量）
   - 路径 4   → 打开「逐条录入助手」，跟着走
```

**iPhone 添加到主屏幕**：Safari 打开上述网址 → 分享按钮 → 「添加到主屏幕」。

### 词库怎么设计才有效

- **重心放在长文本模板**，不要塞城市库和通讯录 —— 系统输入法本来就有全国城市词，联系人姓名系统会自己学。塞进去只会挤占输入码、拖慢 iCloud 同步，还容易误触发（`bj` 会和「不见」打架）。
- **输入码加前缀**避免误触发：`/`、`;`、`@@` 都行，例如 `/dz`。
- **长度 2~4 个字符**。
- **总量控制在 300~1000 条**。超过之后收益急剧下降，冲突率飙升。
- **必须同时有「短语」和「输入码」**。iOS 的「存储」按钮在输入码为空时是灰的，没有输入码的条目等于废条目。

### 仓库结构

```text
.
├── docs/                          # 网页版工具（GitHub Pages 从这里部署）
│   ├── index.html                 # 单文件应用，内嵌拼音表，无外部依赖
│   ├── manifest.webmanifest       # PWA 清单
│   ├── sw.js                      # Service Worker 离线缓存
│   ├── .nojekyll                  # 跳过 Jekyll 处理
│   └── icons/                     # 192 / 512 / 1024 / apple-touch-icon
├── WordVault/                     # SwiftUI iOS App（见下方"关于 iOS App"）
│   ├── WordVaultApp.swift         # App 入口
│   ├── ContentView.swift          # 主 Tab 视图
│   ├── CityListView.swift         # 城市列表
│   ├── ContactListView.swift      # 通讯录列表
│   ├── CustomWordsView.swift      # 自定义词库
│   ├── ExportView.swift           # 导出页面
│   ├── WordEntry.swift            # 数据模型
│   ├── WordStore.swift            # 数据管理
│   ├── ContactsManager.swift      # 通讯录管理
│   ├── PlistGenerator.swift       # plist 生成器
│   └── cities.json                # 城市数据（585 条）
├── scripts/                       # CI 用的 plist 生成脚本
└── .github/workflows/             # build.yml（生成词库）/ pages.yml（可选，Actions 部署）
```

### 部署你自己的副本

本仓库的 `docs/` 目录用 **GitHub Pages 分支部署**，零配置：

1. 仓库 `Settings` › `Pages`
2. Source 选 **Deploy from a branch**
3. Branch 选 `main`，目录选 **`/docs`**，保存
4. 等约 1 分钟，访问 `https://<你的用户名>.github.io/wordvault/`

不默认走 GitHub Actions 是有意的 —— 分支部署不依赖 workflow 权限，不会因为 `GITHUB_TOKEN` 权限不足而失败。
如果你更习惯 Actions，把 `.github/workflows/pages.yml` 启用并把 Source 改成 **GitHub Actions** 即可。

### 本地开发

无需构建步骤，`docs/` 就是最终产物。改完直接刷新浏览器。

想在手机上做真机测试（PWA 与 Service Worker 需要 HTTPS 或 localhost）：

```bash
python3 -m http.server 8000 --directory docs
```

### 关于 iOS App（`WordVault/`）

仓库里的 SwiftUI App 是**早期版本，目前不建议使用**，保留仅供后续参考。它建立在「iPhone 上能导入 plist」这个**错误前提**上，因此：

- 即使成功编译、签名、侧载到 iPhone，它能做的事和网页版完全重叠，**不产生任何额外价值** —— iOS 没有开放写「文本替换」的 API。
- 维护成本却是真实的：GitHub Actions 的 `macos-15` runner 确实能编出 `.ipa`，但必须用 AltStore / Sideloadly + Apple ID 重签名才能安装，**免费签名 7 天过期、最多 3 个 App**；要摆脱限制只有 $99/年 走 TestFlight。

已知问题（如果将来要用，先修这一个）：

- **城市库和通讯录条目全部导出为空输入码，实际不可用。**
  `WordStore.loadCities()` 用 `WordEntry(phrase: name, shortcut: "", category: .cities)` 构造，`ContactsManager` 同理，
  而 `PlistGenerator.generatePlist(from:)` 又不过滤空 `shortcut`。于是导出的 585 条城市词条全是「废条目」—— iOS 在输入码为空时会禁用「存储」按钮。

  最小改动是在生成前过滤掉空输入码：

```swift
static func generatePlist(from words: [WordEntry]) -> Data? {
    let arr: [[String: String]] = words
        .filter { !$0.shortcut.trimmingCharacters(in: .whitespaces).isEmpty }
        .map { ["phrase": $0.phrase, "shortcut": $0.shortcut] }
    return try? PropertyListSerialization.data(fromPropertyList: arr, format: .xml, options: 0)
}
```

  更好的做法是用 `CFStringTransform` 自动补拼音首字母，这样城市库才有意义：

```swift
private static func pinyinInitials(_ s: String) -> String {
    let m = NSMutableString(string: s) as CFMutableString
    CFStringTransform(m, nil, kCFStringTransformMandarinLatin, false)
    CFStringTransform(m, nil, kCFStringTransformStripDiacritics, false)
    return (m as String).split(separator: " ")
        .compactMap { $0.first }.map(String.init).joined()
}
```

- `PlistGenerator.escapeXML` 本身是**正确的**（`&` `<` `>` `"` `'` 全部正确转义），无需改动。把手写 XML 换成 `PropertyListSerialization` 仍是更稳的做法，但不是必须。

### 数据格式参考

iOS 文本替换的 plist：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
  <dict>
    <key>phrase</key>
    <string>北京市朝阳区建国路88号</string>
    <key>shortcut</key>
    <string>/dz</string>
  </dict>
</array>
</plist>
```

- `phrase` — 展开后的内容（要插入的文本）
- `shortcut` — 触发用的输入码，**不能为空**

搜狗自定义短语：`缩写,位置=短语`，例如 `dz,1=北京市朝阳区建国路88号`。

### 隐私

- 所有词条只存在你浏览器的 localStorage，**没有任何网络请求，不上传任何数据**
- 没有账号、没有统计、没有第三方脚本
- 生成的 plist 由你手动放进系统，工具本身不接触你的系统词库
- 请偶尔点一下「JSON 备份」—— 清浏览器缓存会丢数据

### 系统要求

- 网页版：任何现代浏览器（iOS Safari 16+ / Chrome / Edge / Firefox）
- iOS App（实验性）：iOS 16.0+、Xcode 15.0+

### 许可证

MIT License，见 [LICENSE](LICENSE)。

---

## English

**Turn the long text you keep retyping into 2–4 character shortcuts.**

An offline, single-file web tool that produces, encodes and exports phrase libraries for the iOS system keyboard's *Text Replacement* feature.

> 🌐 Live: <https://zzxx872.github.io/wordvault/>

### What it is

WordVault collects the long strings you type over and over — addresses, invoice details, work boilerplate, email signatures — turns them into an iOS *Text Replacement* library, generates **collision-free pinyin shortcuts** for each entry, and exports the result in whichever format your chosen channel needs. It runs in your phone browser: **no Mac, no app install, no account.**

### ⚠️ Read this first: you cannot bulk-import on iPhone

This is the single most important constraint of the whole project, and the point on which most similar tools mislead people:

> **There is no import entry point in iOS "Settings › General › Keyboard › Text Replacement".** There never has been.

Bulk-importing a `.plist` is a **macOS-only** capability: you drag the file into *System Settings › Keyboard › Text Replacement* on a Mac, and iCloud then syncs it **one-way** down to the iPhone. On iOS you can only add entries by hand, one at a time.

The system keyboard has three dictionary layers, and only the first is programmable:

| Layer | Location | Programmatically writable? |
|:--|:--|:--|
| ① Custom phrases / Text Replacement | Settings › General › Keyboard › Text Replacement | No entry point on iPhone; drag-and-drop plist on macOS; iCloud sync |
| ② User dictionary (learned words) | Keyboard learning database | **No public API at all** |
| ③ Third-party IME dictionaries | Sogou / Baidu / WeChat Keyboard | Yes, each with its own proprietary format |

So this project is **not** a "one-click import" tool — that does not exist on iOS. It is:

> **dictionary authoring + shortcut encoding rules + multi-channel distribution**

### Four practical routes

| # | Route | Mac required | Best for |
|:-:|:--|:--:|:--|
| 1 | **Web app → Add to Home Screen** | No | Everyone. Start here, zero cost |
| 2 | **Sogou IME (Windows) → account cloud sync** | No | Users willing to switch IMEs who need true bulk write |
| 3 | **Borrow a Mac and drag the plist once** | Yes (~10 min) | Staying on the system keyboard, one-off setup |
| 4 | **Entry-by-entry assistant** | No | Fallback. Pick only your 50–200 highest-frequency entries |

**Route 2 is the only way to do a real bulk write without ever touching a Mac.** Install Sogou IME on Windows, import the `shortcut,1=phrase` file this tool exports, sign in and sync; then install Sogou IME on the iPhone (with Full Access enabled) under the same account and the dictionary is pushed down automatically. The trade-off is losing the system keyboard's fully-local character.

### Features

- **Table editor** — add, edit, delete, reorder, live search
- **Bulk paste import** — auto-detects five formats: CSV, `shortcut=phrase`, `shortcut,phrase`, tab-separated, and Markdown tables
- **Automatic shortcut generation** — embeds a **6,763-character pinyin table** plus **~160 phrase-level polyphone corrections**, so 重庆→`cq`, 长沙→`cs`, 银行→`yh`, 朝阳→`cyq` all come out right
- **Duplicate audit and one-click repair** — flags duplicate shortcuts, empty shortcuts, over-long phrases and risky short codes, with suggestions you can apply in one click
- **Batched export** — split into batches for incremental entry
- **Multiple export formats** — Apple plist (`PropertyListSerialization`-compatible) / JSON backup / CSV / Sogou `.txt` / Sogou iOS `.bdi`
- **Entry-by-entry assistant** — for iPhone-only users with no Mac: walks each entry through "copy phrase → paste → copy shortcut → paste" with a progress bar, completion ticks, index jump, and a **fast mode** (copy the phrase only; type the shortcut from the pattern) that halves the work
- **PWA** — installable to the home screen, offline-capable via Service Worker
- **Fully local** — entries live only in browser localStorage; zero network requests, no telemetry

### Usage

```text
1. Open https://zzxx872.github.io/wordvault/  (or double-click docs/index.html locally)
2. Click "Bulk import", paste your long text, pick the parse format
3. Click "Generate all shortcuts", then "Fix all issues" to act on the audit suggestions
4. Export according to your route:
   - Route 1 / 3 -> Export Apple plist
   - Route 2     -> Export Sogou format (test with 2-3 entries before doing it in bulk)
   - Route 4     -> Open the entry-by-entry assistant and follow along
```

**Add to Home Screen on iPhone**: open the URL in Safari → Share → *Add to Home Screen*.

### How to design a dictionary that actually helps

- **Focus on long-text templates.** Do not dump city names and contacts in — the system keyboard already knows every city, and it learns contact names on its own. They only crowd out your shortcuts, slow down iCloud sync, and cause misfires (`bj` will fight with the Chinese word 不见).
- **Prefix your shortcuts** to avoid misfires: `/`, `;`, `@@` all work, e.g. `/dz`.
- **2–4 characters long.**
- **Keep the total between 300 and 1,000 entries.** Past that the returns drop off sharply and the collision rate climbs.
- **Every entry needs both a phrase and a shortcut.** iOS greys out the *Save* button when the shortcut is empty, so an entry without one is a dead entry.

### Repository layout

```text
.
├── docs/                          # Web app (GitHub Pages deploys from here)
│   ├── index.html                 # Single-file app, embedded pinyin table, no external deps
│   ├── manifest.webmanifest       # PWA manifest
│   ├── sw.js                      # Service Worker offline cache
│   ├── .nojekyll                  # Skip Jekyll processing
│   └── icons/                     # 192 / 512 / 1024 / apple-touch-icon
├── WordVault/                     # SwiftUI iOS app (see "About the iOS app")
│   ├── WordVaultApp.swift         # App entry point
│   ├── ContentView.swift          # Root tab view
│   ├── CityListView.swift         # City list
│   ├── ContactListView.swift      # Contacts list
│   ├── CustomWordsView.swift      # Custom dictionary
│   ├── ExportView.swift           # Export screen
│   ├── WordEntry.swift            # Data model
│   ├── WordStore.swift            # Persistence
│   ├── ContactsManager.swift      # Contacts access
│   ├── PlistGenerator.swift       # plist generation
│   └── cities.json                # City data (585 entries)
├── scripts/                       # plist generators used by CI
└── .github/workflows/             # build.yml (generate lists) / pages.yml (optional Actions deploy)
```

### Deploying your own copy

The `docs/` folder is served through **GitHub Pages branch deployment** — zero configuration:

1. Repo `Settings` › `Pages`
2. Set Source to **Deploy from a branch**
3. Pick branch `main` and folder **`/docs`**, then save
4. Wait about a minute and open `https://<your-username>.github.io/wordvault/`

Branch deployment is the default here on purpose — it does not depend on workflow permissions and cannot fail because `GITHUB_TOKEN` lacks a scope. If you prefer Actions, enable `.github/workflows/pages.yml` and switch Source to **GitHub Actions**.

### Local development

There is no build step; `docs/` *is* the artifact. Edit and refresh.

To test on a real phone (PWA and Service Worker require HTTPS or localhost):

```bash
python3 -m http.server 8000 --directory docs
```

### About the iOS app (`WordVault/`)

The SwiftUI app in this repo is an **early version and is not recommended for use** — it is kept for reference only. It was built on the **incorrect premise** that a plist can be imported on an iPhone. Consequently:

- Even if you compile it, sign it and sideload it successfully, what it can do overlaps entirely with the web app and **adds zero capability** — iOS simply does not expose an API for writing Text Replacements.
- The maintenance cost, however, is real: GitHub Actions' `macos-15` runner can indeed produce an `.ipa`, but installing it requires AltStore / Sideloadly plus re-signing with an Apple ID. **Free signing expires after 7 days and allows at most 3 apps**; escaping that means $99/year for TestFlight.

Known issues (fix this one first if you ever revisit it):

- **Every city and contact entry is exported with an empty shortcut, which makes them unusable.**
  `WordStore.loadCities()` builds entries as `WordEntry(phrase: name, shortcut: "", category: .cities)`, `ContactsManager` does the same,
  and `PlistGenerator.generatePlist(from:)` does not filter out empty shortcuts. The result is that all 585 exported city entries are
  dead weight — iOS greys out the *Save* button whenever the shortcut is empty.

  The minimal fix is to filter out empty shortcuts before generating:

```swift
static func generatePlist(from words: [WordEntry]) -> Data? {
    let arr: [[String: String]] = words
        .filter { !$0.shortcut.trimmingCharacters(in: .whitespaces).isEmpty }
        .map { ["phrase": $0.phrase, "shortcut": $0.shortcut] }
    return try? PropertyListSerialization.data(fromPropertyList: arr, format: .xml, options: 0)
}
```

  A better fix is to fill in pinyin initials automatically with `CFStringTransform`, which is what would actually make a city list worthwhile:

```swift
private static func pinyinInitials(_ s: String) -> String {
    let m = NSMutableString(string: s) as CFMutableString
    CFStringTransform(m, nil, kCFStringTransformMandarinLatin, false)
    CFStringTransform(m, nil, kCFStringTransformStripDiacritics, false)
    return (m as String).split(separator: " ")
        .compactMap { $0.first }.map(String.init).joined()
}
```

- `PlistGenerator.escapeXML` is itself **correct** — it properly escapes `&`, `<`, `>`, `"` and `'`, so it needs no changes.
  Switching the hand-rolled XML to `PropertyListSerialization` is still the sturdier approach, but not required.

### Data format reference

iOS Text Replacement plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
  <dict>
    <key>phrase</key>
    <string>北京市朝阳区建国路88号</string>
    <key>shortcut</key>
    <string>/dz</string>
  </dict>
</array>
</plist>
```

- `phrase` — the expanded content (what actually gets inserted)
- `shortcut` — the trigger code; **must not be empty**

Sogou custom phrase format: `shortcut,position=phrase`, e.g. `dz,1=北京市朝阳区建国路88号`.

### Privacy

- All entries live only in your browser's localStorage — **no network requests, nothing uploaded**
- No account, no analytics, no third-party scripts
- You install the generated plist into the system yourself; the tool never touches your system dictionary
- Click "JSON backup" occasionally — clearing browser storage will wipe your data

### Requirements

- Web app: any modern browser (iOS Safari 16+, Chrome, Edge, Firefox)
- iOS app (experimental): iOS 16.0+, Xcode 15.0+

### License

MIT License — see [LICENSE](LICENSE).
