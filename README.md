# The Signage Surgeon — Technician App

Flutter + GetX mobile app for vendor-assigned technicians (Firestore `admins.role == "labour"`)
to manage their assigned repair / rebranding / new-signage / cleaning visits — the mobile
counterpart to `/admin/labour` in the web admin panel, backed by the **same Firebase project**.

Two kinds of screens live in this app, and every screen says which it is in its own header/AppBar:

- **Web parity** (Splash, Login, My Work) — a field-for-field, stage-for-stage rebuild of the
  web technician experience. Nothing added, nothing missing.
- **Proposed additions** (Profile, Notifications, Photo Upload, Quotation view, My Performance,
  App Settings, BLE Device Diagnostics) — approved by the client on top of the parity screens,
  but genuinely new: some are fully wired to real Firebase data, some depend on backend pieces
  that don't exist on web yet. Each one's controller/repository has a doc comment explaining
  exactly which. A short amber banner marks these screens in the running app too
  (`AppConstants.showProposedAdditionBanners` — flip to `false` per-screen once you're ready).

---

## 1. Getting started

### Prerequisites

- Flutter 3.24+ (Dart 3.3+)
- A Firebase CLI login with access to the **`signage-surgeon74`** project (same project ID as
  the web app's `.firebaserc`) — ask whoever manages the web app's Firebase project to add you.

### First-time setup

```bash
git clone <this repo>
cd signage-surgeon-technician-app
flutter pub get
```

Firebase is already wired up — see "Firebase configuration" below — so there's no manual
`flutterfire configure` step for Android. Just:

```bash
flutter run
```

### Firebase configuration

`lib/firebase_options.dart` and `android/app/google-services.json` are **committed**, not
gitignored — deliberately: this is client-side config (API key, app id, project id), and
Firebase's own docs are explicit that it isn't a secret — real enforcement is Firestore/Storage
security rules, the same as the web app's `firebase-client.ts` already notes. Committing it
means `git clone && flutter pub get && flutter run` just works, no CLI login required.

Current state:

- **Android**: fully configured against the real `signage-surgeon74` project (`applicationId
  com.thesignagesurgeon.technician`, matching the app registered in Firebase Console).
- **iOS**: not registered yet. `DefaultFirebaseOptions.ios` throws a clear error if hit. To add
  it: register an iOS app in Firebase Console (bundle id `com.thesignagesurgeon.technician`),
  then either run `flutterfire configure` (fastest — needs `firebase login` first) or fill in
  the `ios` block in `lib/firebase_options.dart` by hand from the resulting
  `GoogleService-Info.plist`, the same way `android` was filled in.

If the Android app's config ever needs to change (new API key, rotated project, etc.),
regenerate with `flutterfire configure --project=signage-surgeon74` and commit the result —
same file, same path, no `.gitignore` change needed.

### Pointing at a different backend (staging, etc.)

The only non-Firebase network call this app makes is the shared OTP login endpoint
(`/api/admin/send-otp`, `/api/admin/verify-otp` — the exact same routes the web admin login
uses). It defaults to `https://www.thesignagesurgeon.com`; override with:

```bash
flutter run --dart-define=API_BASE_URL=https://staging.thesignagesurgeon.com
```

---

## 2. Architecture

Feature-oriented, GetX for state/DI/routing, matching the structure agreed up front:

```
lib/
├── main.dart                    Firebase init, LocalStorage init, runApp
├── app/
│   ├── app.dart                 GetMaterialApp: theme, initial route, page list
│   ├── routes/                  Route name constants + the GetPage table
│   ├── bindings/                InitialBinding — app-wide singletons only
│   └── theme/                   Colors/type/spacing lifted 1:1 from the web app's globals.css
├── core/
│   ├── constants/                Firestore collection names, stage strings, API base URL
│   ├── network/                  Dio client, ApiResult<T>, typed exceptions
│   ├── storage/                  SharedPreferences + flutter_secure_storage facade
│   ├── utils/                    date/validation/formatting helpers (unit tested)
│   ├── widgets/                  Button, text field, loader, empty/error states, dialogs
│   └── services/                 Bluetooth adapter + BLE, permissions, logging
├── data/
│   ├── models/                   AdminUserModel, JobModel, NotificationModel
│   ├── datasources/               Firebase Auth, Firestore jobs, OTP REST calls — talk to
│   │                              Firebase/HTTP directly, nothing else does
│   └── repositories/              Business logic + ApiResult wrapping; controllers only ever
│                                  talk to repositories, never a datasource directly
├── features/
│   ├── splash/ login/ dashboard/  Web-parity screens
│   └── profile/ notifications/ photo_upload/ quotation/ reports/ settings/ bluetooth/
│                                  Proposed-addition screens
└── shared/
    ├── widgets/                  StatusBadge, AppBottomNav, ProposedAdditionBanner
    └── extensions/                BuildContext / String helpers
```

Each feature folder: `bindings/` (DI wiring for that route), `controllers/` (GetX
`GetxController`, all state as `Rx`/`Rxn`), `views/` (the screen, `GetView<T>`), `widgets/`
(screen-local widgets, e.g. `JobCard`, `OtpSheet`).

### Where the web parity actually comes from

`features/dashboard` is a direct port of `src/app/admin/labour/page.tsx` in the web repo:

- Same 4 Firestore collections (`repair_requests`, `rebranding_requests`,
  `new_signage_requests`, `cleaning_requests`), same two queries per collection
  (`assignedLabourUid` / `assignedLabourUid2`), same Today/Upcoming/Completed grouping.
- Same stage machine per visit type (`tech_en_route` → `work_in_progress` →
  `site_visit_completed`/`completed`, with the `_2` variants for repair visits).
- Same **inline**, card-level OTP confirmation (not a separate screen) — see
  `JobModel.fromRequestDoc` and `DashboardController.confirmOtp` for the exact mapping; both
  carry doc comments pointing at the equivalent web code.
- Login is the same two-step flow (password → 6-digit email OTP) against the same
  `/api/admin/send-otp` / `verify-otp` routes, restricted here to `role == "labour"` only.

---

## 3. Testing

```bash
flutter test
```

Covers the logic that actually matters to get right — not widget snapshots:

- `test/data/models/job_model_test.dart` — the two-visit vs. single-visit assignment mapping,
  which OTP field feeds which visit, stage-key selection, and the "assigned to both visits"
  edge case.
- `test/core/utils/` — stage-label formatting (must match web's `formatStage()` byte for byte),
  date/"is this today" grouping, and form validation.

---

## 4. Android release configuration

- `android/app/build.gradle`: `applicationId "com.thesignagesurgeon.technician"`, `minSdk 23`
  (required by Firebase Auth + `flutter_reactive_ble`), R8 minify + resource shrinking enabled
  for `release`, ProGuard rules for Firebase/Flutter/BLE in `android/app/proguard-rules.pro`.
- **Launcher icon**: the real brand logo, already generated and committed —
  `android/app/src/main/res/mipmap-*/ic_launcher.png` (legacy, pre-Android-8 devices: navy
  rounded-square background with the logo centered) and `mipmap-*/ic_launcher_foreground.png` +
  `mipmap-anydpi-v26/ic_launcher.xml` + `values/colors.xml`'s `ic_launcher_background` (adaptive
  icon, Android 8+ — logo kept inside the safe zone so it isn't clipped by circle/squircle/
  rounded-square launcher masks). A 512×512 Play Store listing icon is at
  `assets/store/play_store_icon.png`. If the logo ever changes, `dart run flutter_launcher_icons`
  regenerates all of these from `assets/images/logo.png` using the config already in
  `pubspec.yaml`.
- **Signing**: copy `android/key.properties.sample` → `android/key.properties` (gitignored)
  once you've generated an upload keystore:

  ```bash
  keytool -genkey -v -keystore ~/signage-surgeon-technician-upload.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```

  Without `key.properties`, `flutter build apk --release` still succeeds (falls back to the
  debug key) so local release builds work out of the box — just never ship a Play Store build
  signed that way.

  ```bash
  flutter build appbundle --release   # Play Store
  flutter build apk --release         # sideload / testing
  ```

- **iOS**: not scaffolded in this repo yet (Xcode project files need the real Flutter SDK to
  generate correctly, which wasn't available in the environment this was built in). Run
  `flutter create --platforms=ios .` once you have Flutter installed locally, then re-run
  `flutterfire configure` to register the iOS app too.

---

## 5. What's real vs. simulated in the proposed additions

| Screen | Data source | Status |
|---|---|---|
| Profile (view/edit, change password) | `admins/{uid}` + Firebase Auth | Real — new write access beyond what web grants a technician today |
| Photo Upload | Firebase Storage + new `technicianPhotoUrls` field | Real — `technicianPhotoUrls` doesn't exist in the current web schema |
| Quotation (read-only) | `finalQuotation` field on the request doc | Real — field already exists, just never surfaced to technicians before |
| My Performance | Job counts computed from the technician's own assigned docs | Real counts; **rating average is a placeholder** — `ratings` documents on web have no technician reference (`admin/ratings/page.tsx` only stores `requestId` + `stars`), so it can't be computed until that schema changes |
| Notifications | New `technician_notifications/{uid}/items` collection | Read path is real; nothing currently *writes* to this collection (no Cloud Function/trigger exists yet) — shows the correct empty state until one is added |
| BLE Device Diagnostics | `flutter_reactive_ble` | Scanning/connecting is real. The "live readings" panel is explicitly simulated (`BleDiagnosticsSnapshot.isSimulated`) — no signage-controller BLE protocol (service/characteristic UUIDs) has been provided yet. See the `TODO(hardware-protocol)` in `core/services/ble_service.dart` |

---

## 6. Design reference

Brand colors/type in `app/theme/` are sampled directly from the web app's `globals.css`
(`--brand-red #C92223`, `--brand-yellow #FECC00`, `--brand-navy #0A1628`, `--brand-offwhite
#FAF9F6`, Poppins). The client-approved clickable mockup this app was built from covers every
screen listed above.
