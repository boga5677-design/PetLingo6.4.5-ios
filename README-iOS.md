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
