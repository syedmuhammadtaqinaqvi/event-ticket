# ticket-mobile-app

DonorHub Events mobile ticket app — lookup, claim on device, and enter at the gate.

**Entry:** NFC tap (primary on Android when NFC is on) or **rotating QR fallback** every 30s (non-NFC / NFC off). Same offline `qrSecret` rebuilds both payloads after claim.

**Device ID:** Android uses `ANDROID_ID` after fresh install (survives reinstall). Existing installs keep their stored ID until cleared.

## Stack

- Flutter
- API base: `https://api.donorhub.cloud` (override with `--dart-define=API_BASE_URL=...`)

## Run

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
flutter test test/api_smoke_test.dart   # live API (network required)
```
