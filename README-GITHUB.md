# PetLingo Kids iOS

這是 PetLingo Kids 的 iPhone + iPad Universal App 專案。

## GitHub Actions

本專案只保留一個 iOS workflow：

- `.github/workflows/ios.yml`

它會使用 macOS runner 與 Xcode 建置 iOS Simulator 版本，並上傳：

- `PetLingoKids-iOS-Simulator.zip`

## 重要

請將本專案建立為「全新的 GitHub repository」，不要覆蓋到先前含有 Android / Gradle / Appknox workflow 的舊 repository。

正常的 Actions 不應出現：

- `gradlew`
- `chmod +x gradlew`
- `appknox`
- `report.sarif`
- `upload-sarif`

## Xcode

直接開啟：

`PetLingoKids.xcodeproj`

Scheme：

`PetLingoKids`
