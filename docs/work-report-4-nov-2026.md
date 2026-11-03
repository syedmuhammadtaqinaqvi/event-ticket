# Work Report — Event Ticket (DonorHub)

**Date:** 4 November 2026  
**Project:** Flutter mobile ticket app (`com.eventpass.event_ticket`)  
**API:** `https://api.donorhub.cloud`  
**Branch:** `3-nov-2026` (commit `410249c`)  
**Repositories:**

- https://github.com/muhammadkhan123786/ticket-mobile-app.git  
- https://github.com/syedmuhammadtaqinaqvi/event-ticket.git  

---

## 1. Executive summary

Delivered a production-oriented **lookup → claim → Pass** flow for DonorHub event tickets, aligned with the updated public tickets API (NFC-first entry, shared rotating payload for NFC + QR). Work focused on **stable device binding after reinstall**, **Android NFC Host Card Emulation (HCE)**, **rotating door codes**, clearer **lookup/claim errors**, and **Android build stability**.

---

## 2. Scope completed

| Area | Outcome |
|------|---------|
| Ticket lookup & claim | Event ID + `TKT-…` reference; preview; claim binds ticket to device |
| Device identity | Upgrade-safe prefs ID; fresh Android install uses `ANDROID_ID`; iOS Keychain backfill for reinstall |
| Reinstall recovery | Auto idempotent reclaim when server reports same device or `boundDeviceId` matches local ID |
| Entry at gate | Android: NFC tap (Type 4 NDEF HCE); fallback rotating QR every 30s when `qrSecret` present |
| Security / UX | `FLAG_SECURE` when QR backup visible; screenshot discouraged on sensitive QR view |
| Error messaging | Separate copy for not found vs wrong device; device label in footnotes; no mixed 404/device text |
| Quality | Unit tests (device ID, reclaim flow, rotating codec, input normalizer); `flutter analyze` clean |
| Documentation | Android QA checklist (`docs/android-qa-reinstall.md`) |

---

## 3. Technical details

### 3.1 Device ID (`StableDeviceIdResolver`)

- **Existing users:** keep `donorhub_device_id` from SharedPreferences (no forced migration).
- **Fresh Android install:** persist `Settings.Secure.ANDROID_ID` (survives reinstall on same hardware).
- **Fresh iOS install:** UUID in Keychain; on upgrade, prefs ID is copied to Keychain when missing.
- Lookup and claim always send resolved `deviceId` after `DeviceIdService.warmUp()`.

### 3.2 Lookup & reclaim (`TicketFlowController`)

- Validates full Event UUID and normalized `TKT-` reference.
- **Before** “other device” errors: checks `boundDeviceId == localDeviceId` and auto-claim for Pass/QR.
- Wallet fallback if lookup flags conflict but device wallet lists the ticket.
- `LookupErrorKind` drives header title and footnotes (not found / different device / validation / network).

### 3.3 Rotating entry payload (`RotatingEntryPayloadCodec`)

- Offline HMAC payload (`DHB1R` prefix) shared by **NFC NDEF** and **QR** when API returns `qrSecret` + period (default 30s).
- Pass screen timer republishes payload to HCE on each period step.

### 3.4 Android NFC HCE

- Service: `TicketHceService` — AID `D2760000850101`, category **other**.
- Protocol: `TicketNfcType4Protocol` (SELECT NDEF app, CC `E103`, NDEF `E104`, READ BINARY).
- Payload: `TicketNfcPayloadHolder` — NDEF Text or MIME from API `nfcRecordType` / `nfcMimeType`.
- Flutter bridge: method channel `com.eventpass.event_ticket/nfc_entry`.
- UI: `EntryPassPanel` — “Hold phone to reader”, QR backup, NFC settings hint if not default HCE app.
- Resources: `strings.xml` (`app_name`), `ticket_apdu_service.xml`.

### 3.5 Build fixes

- Missing `@string/app_name` for HCE XML — added `values/strings.xml`.
- `CardEmulation.isDefaultServiceForCategory` (correct API for HCE default check).
- Removed unused `nfc_manager` dependency; hardware checks via native `NfcAdapter`.

---

## 4. Testing performed

| Test | Result |
|------|--------|
| `flutter analyze` | Pass |
| `flutter test` (unit + widget + reclaim) | Pass |
| `flutter build apk --debug` | Pass |
| Live API smoke tests | Optional tag `live-api` (network) |
| Physical NFC gate reader | **Not verified in office** — requires venue hardware or second Android with NDEF read app |
| Device QA | OnePlus 6T: Pass shows NFC mode, rotating timer, NFC icon on; entry validated via QR backup path |

---

## 5. How to verify NFC (OnePlus 6T / Android)

1. Claim ticket → **Pass** → NFC on → “Hold phone to reader”.
2. Optional: **Settings → NFC → Contactless / Other** → set **Event Ticket** as default.
3. At venue: back of phone (upper area) on gate NFC pad 1–2 seconds.
4. Without a reader: use **Show QR backup** or second phone with **NFC TagInfo** to read NDEF.
5. Engineering: `adb logcat -s TicketHceService` while tapping a reader.

---

## 6. Known limitations & dependencies

- **404 on lookup:** Server has no row for that Event ID + TKT pair (wrong email/copy) — not fixed by reinstall.
- **Legacy binding:** Tickets claimed under old random UUID may need **staff unbind** once before reclaim on stable ID.
- **iOS:** No HCE; QR (and rotating QR when secret present) at gate.
- **NFC acceptance:** Gate software must read Type 4 NDEF on AID `D2760000850101` and validate same payload as QR.

---

## 7. Deliverables & links

| Item | Location |
|------|----------|
| Source (branch) | `3-nov-2026` @ `410249c` on both GitHub repos above |
| QA notes | `docs/android-qa-reinstall.md` |
| This report | `docs/work-report-4-nov-2026.md` |

---

## 8. Suggested next steps

1. Venue pilot: one tap + one QR scan on production reader; confirm DonorHub validation rules.
2. Optional: in-app “Copy device ID for staff” on wrong-device screen.
3. Optional: JVM unit tests for `TicketNfcType4Protocol` APDU sequences.
4. Merge `3-nov-2026` → `main` after stakeholder sign-off.

---

**Prepared for:** DonorHub Event Ticket mobile initiative  
**Report date:** 4 November 2026  
