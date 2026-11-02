# event-ticket

DonorHub Events mobile ticket app — lookup, claim on device, and show door QR (`qrPayload` from API).

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
