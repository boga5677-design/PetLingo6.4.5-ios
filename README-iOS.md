# PetLingo iOS v6.0

此專案是由 PetLingo Android v6.x 原生移植為 **SwiftUI iOS 版**，保留原本的主視覺、首頁功能配置、GEPT/TOEIC 單字資料、片語、閱讀題組、收藏、錯題、筆記、歷史、每日任務、聽力及口說功能。

## 開啟方式
1. 使用 macOS + Xcode 16（或更新版本）。
2. 雙擊 `PetLingo.xcodeproj`。
3. 選擇 PetLingo target → Signing & Capabilities → 選擇自己的 Apple Developer Team。
4. Bundle Identifier 若與既有 App 衝突，可改為自己的識別碼。
5. 選擇 iPhone 模擬器或實機後 Run。

## iOS 權限
- Microphone：口說錄音
- Speech Recognition：英語語音辨識與評分

## 口說防干擾
按「播放示範」後，App 會等待語音播放完成，再額外間隔約 0.5 秒才開啟麥克風，以避免示範音被辨識成使用者口說。

## 主要對應
- Android TextToSpeech → `AVSpeechSynthesizer`
- Android RecognizerIntent → `Speech / SFSpeechRecognizer`
- SharedPreferences → `UserDefaults + Codable`
- Jetpack Compose → SwiftUI

## GitHub Actions / Xcode 26
專案已附上 `.github/workflows/ios-build.yml` 與共享 `PetLingo.xcscheme`。

CI 不再指定 `name=iPhone 16e` 搭配隱含的 `OS=latest`。某些 GitHub runner 會同時安裝多個 iOS Runtime，而特定 iPhone 型號只存在較舊 Runtime；此時 `xcodebuild` 會因找不到「該型號 + latest OS」而以 exit code 70 結束。

目前 workflow 改用：

```bash
-destination 'generic/platform=iOS Simulator'
```

這適合做 CI 編譯驗證，也不依賴 runner 上剛好存在某一台 iPhone simulator。

若要在指定的 iPhone 16e 上執行測試，請明確指定該 runner 實際存在的 OS，例如日誌中的：

```bash
-destination 'platform=iOS Simulator,name=iPhone 16e,OS=26.2'
```

或直接使用該 simulator 的 UDID。


## iPad / Universal App
- 支援 iPhone 與 iPad (`TARGETED_DEVICE_FAMILY = 1,2`)。
- iPad 支援直向、倒置直向與左右橫向。
- iPad regular width 下首頁改為 3 欄功能卡，學習中心改為 2 欄。
- 寬畫面內容設最大寬度，避免卡片在 11/13 吋 iPad 上被過度拉伸。
- GitHub Actions 使用 generic iOS Simulator 建置，不綁定特定 iPhone/iPad 型號。

## v6.0.3 GitHub Actions 修正
此版本為 iPhone + iPad Universal App (`TARGETED_DEVICE_FAMILY = 1,2`)。CI 使用 `generic/platform=iOS Simulator`，不綁定 iPhone 16e。若 Actions 日誌仍出現 `name=iPhone 16e`，請刪除 GitHub 倉庫內的舊 workflow；詳見 `IMPORTANT-GITHUB-ACTIONS.md`。
