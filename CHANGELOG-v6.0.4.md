# PetLingo iOS v6.0.4 — Universal Stable

- iPhone + iPad Universal App maintained with `TARGETED_DEVICE_FAMILY = 1,2`.
- GitHub Actions no longer targets a named simulator such as iPhone 16e.
- All CI builds use `generic/platform=iOS Simulator`.
- CI now builds both Debug and Release simulator configurations.
- CI verifies the shared `PetLingo` scheme before building.
- CI verifies the built App's `UIDeviceFamily` contains both `1` (iPhone) and `2` (iPad).
- Simulator artifact name updated to `PetLingo-v6.0.4-iPhone-iPad-Simulator.zip`.
- Existing iPad adaptive layout and all four iPad orientations are retained.

## Important when replacing an older repository

Delete obsolete workflow files from `.github/workflows/` before uploading this version. The package itself contains only `ios-build.yml`.
