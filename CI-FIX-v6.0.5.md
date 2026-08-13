# PetLingo iOS v6.0.5 CI Fix

This package removes the incompatible Android/Appknox workflow that caused:

- `chmod: cannot access 'gradlew'`
- missing `report.sarif`
- CodeQL SARIF upload failures

The repository now contains only `.github/workflows/ios-build.yml` for CI.
It builds PetLingo as a universal iPhone + iPad app using a generic iOS Simulator destination, so it does not depend on a specific simulator model or OS version.
