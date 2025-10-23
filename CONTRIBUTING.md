# 貢獻指南

感謝你對 **dandori** 的興趣！我們歡迎各種形式的貢獻。

## 🐛 回報問題

發現 bug 或有功能建議？請[開 issue](https://github.com/YOUR_USERNAME/dandori/issues/new)。

### Bug 回報範本

```markdown
**環境資訊**
- macOS 版本：
- Shell：zsh / bash
- 執行指令：

**預期行為**
說明你預期應該發生什麼

**實際行為**
說明實際發生了什麼

**錯誤訊息**
```bash
貼上完整錯誤訊息
```

**重現步驟**
1. 執行 ...
2. 觀察到 ...
```

## 💡 功能建議

想要新功能？歡迎討論！請先開 issue 說明：

- 功能的使用情境
- 預期的使用方式
- 為什麼這個功能有用

## 🔧 提交程式碼

### 開發流程

1. **Fork 專案**
   ```bash
   # 在 GitHub 上 fork 專案
   git clone https://github.com/taiansu/dandori.git
   cd dandori
   ```

2. **建立分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix
   ```

3. **進行修改**
   - 遵循現有的程式碼風格
   - 保持函式小而專注
   - 加入適當的錯誤處理

4. **測試修改**
   ```bash
   # 本地測試
   ./setup.sh --ci

   # 測試不同語言組合
   ./setup.sh --langs=python --ci
   ./setup.sh --langs=python,node --ci
   ```

5. **提交變更**
   ```bash
   git add .
   git commit -m "feat: 加入新功能的簡短描述"
   # 或
   git commit -m "fix: 修復問題的簡短描述"
   ```

6. **Push 並建立 Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

   然後在 GitHub 上建立 Pull Request。

### Commit 訊息規範

使用語義化的 commit 訊息：

- `feat:` 新功能
- `fix:` Bug 修復
- `docs:` 文件更新
- `style:` 程式碼格式（不影響功能）
- `refactor:` 重構（不改變功能）
- `test:` 測試相關
- `chore:` 建置或工具相關

範例：
```
feat: 加入 Ruby 語言支援
fix: 修正 mise activate 路徑錯誤
docs: 更新安裝時間說明
```

### 程式碼風格

- 使用 4 空格縮排
- 函式名稱使用 snake_case
- 適當的註解說明複雜邏輯
- 保持一致的錯誤處理風格

### Pull Request 檢查清單

在提交 PR 前，請確認：

- [ ] 程式碼通過所有測試
- [ ] 加入必要的文件更新
- [ ] Commit 訊息清楚明確
- [ ] 沒有不必要的檔案變更
- [ ] 功能在 macOS 最新版本測試過

## 🧪 測試

### 自動化測試

專案使用 GitHub Actions 自動測試。你的 PR 會自動執行測試。

查看測試設定：[.github/workflows/test.yml](.github/workflows/test.yml)

### 本地測試

```bash
# 快速測試（不執行 mise install）
./setup.sh --langs=python --ci

# 完整測試（包含 mise install）
# 注意：首次執行可能需要 30-40 分鐘
./setup.sh --ci

# 測試冪等性
./setup.sh --ci
./setup.sh --ci  # 第二次應該快速完成
```

## 📝 文件貢獻

改善文件同樣重要！歡迎：

- 修正錯字或不清楚的說明
- 加入使用範例
- 翻譯成其他語言
- 改善 README 結構

## 🌍 在地化

想要加入其他語言的支援？歡迎貢獻翻譯：

1. 建立 `README.{lang}.md`（例如 `README.ja.md` 日文版）
2. 翻譯主要內容
3. 在主 README 加入語言連結

## ❓ 問題討論

有任何疑問？可以：

- 開 [issue](https://github.com/YOUR_USERNAME/dandori/issues) 討論
- 在 [Discussions](https://github.com/YOUR_USERNAME/dandori/discussions) 發問

## 🙏 感謝

感謝每一位貢獻者！你的貢獻讓 dandori 變得更好。

---

**記住段取り的精神** - 做好準備，追求完美 ✨
