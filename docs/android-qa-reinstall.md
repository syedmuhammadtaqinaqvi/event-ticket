# Manual QA — Android reinstall + QR recovery

Device: wireless Android (e.g. V2111).

1. **Fresh claim**
   - Install app → enter Event ID + `TKT-…` → Claim → Pass shows QR.

2. **Reinstall recovery**
   - Uninstall app completely.
   - Reinstall → enter **same** Event ID + `TKT-…`.
   - Expect: lookup → automatic reclaim → **Pass with QR** (no manual Claim).

3. **NFC tap (Android with NFC on)**
   - Pass screen → **Hold phone to reader** (not QR).
   - Payload rotates every 30s; optional **Show QR backup**.
   - If tap fails: **Settings → NFC** → set **Event Ticket** as default contactless app (Other), or use QR backup.

4. **Screenshot protection**
   - On Pass with **QR backup** visible, try screenshot → should be blocked on Android.

4. **Legacy binding (optional)**
   - Ticket claimed **before** stable ANDROID_ID update, then uninstall → may show staff unbind message (expected until organizer unbinds).
