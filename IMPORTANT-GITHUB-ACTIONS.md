# GitHub Actions 必做：刪除舊的 iPhone 16e workflow

如果 Actions 日誌仍出現：

```text
xcodebuild build-for-testing ... -destination "platform=iOS Simulator,name=iPhone 16e"
```

代表 GitHub 倉庫內仍存在舊的 workflow。新版專案不會執行這個指令。

請到 GitHub 倉庫的 `.github/workflows/`，刪除或停用所有仍包含以下任一內容的舊 `.yml/.yaml`：

```text
name=iPhone 16e
name:iPhone 16e
OS=latest
```

最安全的作法是：先刪除 GitHub 倉庫現有的 `.github/workflows` 資料夾，再把本 ZIP 的 `.github/workflows/ios-build.yml` 完整上傳。

新版使用：

```text
-destination 'generic/platform=iOS Simulator'
```

因此不依賴 GitHub runner 是否保留某一台特定 iPhone/iPad 模擬器。
