# 词库助手 (WordVault)

一款帮助 iOS 用户批量管理文本替换词库的 App。

## 功能特性

- 📍 **城市词库**: 内置 585 个中国城市名，一键导出到 iOS
- 👥 **通讯录词库**: 自动导入联系人姓名，支持自动导入开关
- ✏️ **自定义词库**: 添加、管理自己的词汇
- 📤 **批量导出**: 生成 iOS 原生支持的 `.plist` 文件
- 💾 **数据备份**: 支持 JSON 格式导入导出

## iOS 导入方法

1. 打开 App，选择要导出的词库分类
2. 点击「导出 plist 文件」
3. 选择「存储到文件」或通过分享菜单
4. 打开「设置」→「通用」→「键盘」→「文本替换」
5. 点击右上角「+」→ 选择「导入短语...」
6. 选择导出的 `.plist` 文件

## 技术细节

### iOS 文本替换 plist 格式

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <dict>
        <key>phrase</key>
        <string>北京</string>
        <key>shortcut</key>
        <string></string>
    </dict>
</array>
</plist>
```

- `phrase`: 要添加的词汇
- `shortcut`: 快捷触发（留空 = 直接添加到词典）

## 安装运行

### 方式一: Xcode 打开

```bash
cd WordVault.xcodeproj
open WordVault.xcodeproj
```

在 Xcode 中选择模拟器，点击运行。

### 方式二: 命令行构建

```bash
xcodebuild -project WordVault.xcodeproj -scheme WordVault -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 项目结构

```
WordVault/
├── WordVaultApp.swift      # App 入口
├── ContentView.swift       # 主 Tab 视图
├── CityListView.swift      # 城市列表
├── ContactListView.swift   # 通讯录列表
├── CustomWordsView.swift   # 自定义词库
├── ExportView.swift        # 导出页面
├── WordEntry.swift         # 数据模型
├── WordStore.swift         # 数据管理
├── ContactsManager.swift   # 通讯录管理（含自动权限）
├── PlistGenerator.swift    # plist 生成器
├── cities.json             # 城市数据 (585个城市)
└── Info.plist              # 应用配置
```

## 隐私说明

- 通讯录权限仅用于导入联系人姓名
- 所有数据存储在本地，不会上传
- 不需要「完全访问」权限（相比第三方输入法更安全）

## 系统要求

- iOS 16.0+
- Xcode 15.0+

## 许可证

MIT License
