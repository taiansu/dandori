![Test Status](https://github.com/taiansu/dandori/actions/workflows/test.yml/badge.svg)
![License](https://img.shields.io/github/license/taiansu/dandori)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)

# 🍽️ dandori (段取り)

> 為你的 macOS 開發環境做好段取り

**dandori**（段取り）是日本職人文化中的核心概念，意指「在開始工作前做好完美的準備」。就像壽司師傅備料、木工師傅排列工具，我們為你的開發環境做好段取り。

一行指令，自動安裝並設定你的 macOS 開發環境。

## ✨ 特色

- 💡 **零設定安裝** - 一行指令完成所有設定
- 🖥️ **正規環境配置** - 使用 [Homebrew](https://brew.sh)、[mise](https://mise.jdx.dev) 標準開發環境設定慣例，易於維護
- 📦 **必備開發工具** - Git、Ripgrep、fzf 等開發必備工具
- 🔧 **可選擇語言** - 預設安裝常用語言，也可自訂組合
- ♻️ **冪等性** - 重複執行安全，已安裝的工具自動跳過

## 🚀 快速開始

### 預設安裝（Python, Elixir, Node）

```bash
curl -fsSL https://dandori.phx.tw | bash
```

### 自訂語言組合

```bash
curl -fsSL https://dandori.phx.tw | bash -s -- --langs=python,rust,ruby
```

### 互動式選擇

```bash
curl -fsSL https://dandori.phx.tw | bash -s -- --interactive
```

## 📦 安裝內容

### 基礎工具
- **Homebrew** - macOS 套件管理器
- **Git** - 版本控制
- **mise** - 開發工具版本管理
- **ripgrep** - 快速文字搜尋
- **fzf** - 模糊搜尋工具
- **fd** - 檔案搜尋工具

### 支援的語言環境

| 選項 | 語言 | 說明 |
|------|------|------|
| `python` | Python | 最新穩定版 |
| `elixir` | [Elixir + Erlang](https://elixir-lang.org/) | 同時安裝對應的 Erlang 版本 |
| `node` | [Node.js + npm](https://nodejs.org/en) | JavaScript 執行環境 |
| `rust` | [Rust + Cargo](https://rust-lang.org/) |  |
| `ruby` | [Ruby + gem](https://www.ruby-lang.org/en/) |  |
| `zig` | [Zig](https://ziglang.org/) |  |
| `swift` | [Swift](https://swift.org/) |  |
| `bun` | [Bun](https://bun.com/) |  |

**預設組合**: `python`, `elixir`, `node`

*註*: 若需要其它程式語言，後續可用 `mise` 手動輕鬆安裝。

## 🎮 使用方式

### 基本用法

```bash
# 使用預設語言組合
curl -fsSL https://dandori.phx.tw | bash

# 指定語言（逗號分隔，不含空格）
curl -fsSL https://dandori.phx.tw | bash -s -- --langs=python,rust

# 互動式選擇
curl -fsSL https://dandori.phx.tw | bash -s -- --interactive

# Dry run 模式 (只偵測並列印安裝計劃，不實際執行)
curl -fsSL https://dandori.phx.tw | bash -s -- --dry
```

### 互動模式

使用 `--interactive` 參數時，會顯示選單：

```
請選擇要安裝的語言環境 (輸入數字組合，例如 134)
直接按 Enter 使用預設: Python, Elixir, Node

1) Python
2) Elixir (同時安裝對應 Erlang 版本)
3) Node
4) Rust
5) Ruby
6) Zig
7) Swift
8) Bun

你的選擇: _
```

輸入數字組合即可，例如：
- 輸入 `134` → 安裝 Python, Node, Rust
- 直接按 Enter → 安裝預設組合 (Python, Elixir, Node)

### CI/CD 模式

在持續整合環境中使用 `--ci` 參數跳過所有互動：

```bash
./setup.sh --ci
./setup.sh --langs=python,node --ci
```

## 🔒 安全建議

建議首次使用時先檢視腳本內容：

```bash
# 下載腳本
curl -fsSL https://dandori.phx.tw > setup.sh

# 檢視內容
less setup.sh

# 確認無誤後執行
bash setup.sh
```

或直接查看 [GitHub 原始碼](https://github.com/taiansu/dandori)。

## ⚙️ 運作原理

1. **檢查 Homebrew** - 若未安裝則自動安裝 (可能需要輸入使用者密碼)
2. **安裝基礎工具** - 使用 Homebrew 安裝 git, mise, ripgrep, fzf
3. **產生 mise 設定** - 建立 `~/.config/mise/config.toml`
4. **設定 Shell 整合** - 自動加入 `mise activate` 到你的 shell rc 檔
5. **安裝語言環境** - 使用 mise 安裝選定的程式語言

### 設定檔位置

設定檔皆依標準開發者慣例配置

- mise 設定檔：`~/.config/mise/config.toml`
- 語言安裝目錄：`~/.local/share/mise/installs/`
- Shell 設定：`~/.zshrc` 或 `~/.bashrc`

## ⏱️ 安裝時間

| 語言組合 | 預估時間（首次） | 說明 |
|---------|----------------|------|
| Python only | ~5 分鐘 | 較輕量 |
| Python + Node | ~8 分鐘 | 常見組合 |
| Python + Elixir + Node | ~30-40 分鐘 | Erlang 需要編譯 |
| All languages | ~45-60 分鐘 | 包含 Rust 編譯 |

> 💡 **提示**: Erlang 和 Rust 有可能需要從原始碼編譯，首次安裝較慢。後續版本更新會使用預編譯版本，速度較快。

## 🔧 管理已安裝的語言

安裝完成後，你可以使用 mise 管理語言版本：

```bash
# 查看已安裝的語言
mise list

# 更新到最新版本
mise upgrade

# 安裝特定版本
mise install python@3.11

# 設定專案特定版本（在專案目錄下）
mise use python@3.11

# 查看 mise 狀態
mise doctor
```

## 🐛 疑難排解

### Homebrew 安裝失敗

```bash
# 檢查網路連線
ping github.com

# 手動安裝 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/setup.sh)"

# 重新執行 dandori
curl -fsSL https://dandori.phx.tw | bash
```

### mise 安裝語言失敗

```bash
# 查看詳細錯誤訊息
mise install -v

# 檢查系統依賴
mise doctor

# 手動安裝特定語言
mise install python@latest
```

### Shell 找不到已安裝的語言

```bash
# 確認 mise activate 已設定
grep "mise activate" ~/.zshrc  # 或 ~/.bashrc

# 手動載入 mise
eval "$(mise activate zsh)"  # 或 bash

# 重新啟動終端機
```

### 權限問題

某些操作需要 sudo 權限（例如安裝 Homebrew）。如果遇到權限錯誤：

```bash
# 確認你有 admin 權限
groups | grep admin

# 清除 Homebrew cache（如果磁碟空間不足）
brew cleanup
```

## 🤝 貢獻

歡迎貢獻！請查看 [貢獻指南](CONTRIBUTING.md)。

### 開發

```bash
# Clone repository
git clone https://github.com/taiansu/dandori.git
cd dandori

# 測試腳本
./setup.sh --langs=python --ci

# 執行測試
# GitHub Actions 會自動測試所有場景
```

### 測試

專案使用 GitHub Actions 進行自動化測試：

- ✅ 預設安裝測試
- ✅ 自訂語言組合測試
- ✅ 冪等性測試
- ✅ 跨 macOS 版本相容性

查看 [.github/workflows/test.yml](.github/workflows/test.yml) 了解測試詳情。

## 📄 授權

MIT License - 詳見 [LICENSE](LICENSE)

## 🙏 致謝

- [mise](https://mise.jdx.dev) - 優秀的開發工具版本管理器
- [Homebrew](https://brew.sh) - macOS 必備套件管理器

## 📚 相關資源

- [mise 官方文件](https://mise.jdx.dev)
- [Homebrew 文件](https://docs.brew.sh)

---

**dandori** - 為你的開發環境做好段取り 🍽️

Made with ❤️ for developers who value preparation
