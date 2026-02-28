# R2 File Manager — Flutter Mobile App

A fully-featured **Cloudflare R2 file manager** for Android & iOS, matching the design and functionality of the companion web app.

---

## Design

| Token | Value |
|---|---|
| Background | `#0A0A0A` |
| Card / Surface | `#161616` / `#0F0F0F` |
| Border | `#2A2A2A` |
| Primary (orange) | `#F97316` |
| Success (green) | `#22C55E` |
| Destructive (red) | `#EF4444` |
| Muted text | `#A1A1AA` / `#71717A` |

Dark-only theme. No light mode.

---

## Features

| Feature | Status |
|---|---|
| Firebase Email/Password Auth | ✅ |
| List files & folders (R2) | ✅ |
| Folder navigation (breadcrumb) | ✅ |
| Upload files (presigned PUT) with progress | ✅ |
| Download (presigned GET, opens in browser) | ✅ |
| Create folder | ✅ |
| Rename file (copy + delete) | ✅ |
| Delete (single & bulk, recursive folder delete) | ✅ |
| Share link with configurable expiry | ✅ |
| Search / filter by file type | ✅ |
| Multi-select & bulk actions | ✅ |
| Pull-to-refresh | ✅ |
| Shimmer loading skeleton | ✅ |

---

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── firebase_options.dart       # Firebase config (fill in your values)
├── theme/
│   └── app_theme.dart          # Colors + ThemeData
├── models/
│   └── file_item.dart          # FileItem, FolderItem, ListResult
├── services/
│   ├── auth_service.dart       # Firebase Auth wrapper
│   ├── r2_service.dart         # Cloudflare R2 / S3 SigV4 client
│   └── file_manager_provider.dart  # ChangeNotifier state
├── screens/
│   ├── auth_wrapper.dart       # Routes login ↔ file manager
│   ├── login_screen.dart       # Login UI (mirrors web)
│   └── file_manager_screen.dart    # Main file manager shell
└── widgets/
    ├── breadcrumb_nav.dart
    ├── toolbar.dart            # Search + type filter chips
    ├── file_item_tile.dart     # File row with inline actions
    ├── folder_item_tile.dart   # Folder row
    ├── bulk_action_bar.dart    # Bulk selection action bar
    ├── upload_progress_bar.dart
    ├── file_list_skeleton.dart # Shimmer loading
    ├── base_bottom_sheet.dart  # Shared sheet scaffold + form helpers
    ├── new_folder_bottom_sheet.dart
    ├── rename_bottom_sheet.dart
    ├── delete_bottom_sheet.dart
    ├── share_bottom_sheet.dart
    └── share_link_bottom_sheet.dart
```

---

## Setup

### 1 — R2 Credentials

Edit `.env` at project root:

```env
R2_ENDPOINT=https://<account_id>.r2.cloudflarestorage.com
R2_ACCESS_KEY_ID=<your_key>
R2_SECRET_ACCESS_KEY=<your_secret>
R2_BUCKET_NAME=<your_bucket>
R2_REGION=auto
```

### 2 — Firebase

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Authentication → Email/Password**.
3. Add an **Android app** (package: `com.filefort.app`) and an **iOS app** (bundle ID: `com.filemanager.r2FileManager`).
4. Download `google-services.json` → place in `android/app/`.
5. Download `GoogleService-Info.plist` → place in `ios/Runner/`.
6. Fill in `lib/firebase_options.dart` with your project's values
   *(or run `flutterfire configure` to auto-generate it)*.

### 3 — R2 CORS (required for direct presigned uploads)

In your R2 bucket settings → CORS, add:

```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "PUT", "DELETE", "HEAD"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 3600
  }
]
```

### 4 — Install & Run

```bash
flutter pub get
flutter run
```

---

## Architecture

```
Flutter UI
    │
    ▼
FileManagerProvider  (ChangeNotifier)
    │
    ▼
R2Service  (pure Dart, AWS SigV4)
    │
    ▼
Cloudflare R2  (S3-compatible API)
```

- **Auth**: Firebase Auth → `AuthWrapper` stream-listens and routes.
- **State**: `Provider` (`ChangeNotifier`) for file list, selection, uploads, search.
- **R2 ops**: Pure Dart `http` + manual AWS SigV4 signing (no native SDK needed).
- **Upload progress**: `dart:io HttpClient` chunked write → progress events → `LinearProgressIndicator`.
- **Presigned URLs**: Generated client-side for download/share; opened via `url_launcher`.
