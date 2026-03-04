# Quick Start Guide 🚀

## Your Flutter R2 File Manager is Built! ✅

The web version is ready in `build/web/`. Follow these steps to run or deploy it.

---

## 1️⃣ Run Locally (Web)

```bash
# Serve the web build
cd build/web
python3 -m http.server 8000
```

Then open: http://localhost:8000

---

## 2️⃣ Deploy to Cloudflare Pages

```bash
# Install Wrangler CLI
npm install -g wrangler

# Deploy
wrangler pages deploy build/web --project-name=r2-file-manager
```

---

## 3️⃣ Deploy to Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --dir=build/web --prod
```

---

## 4️⃣ Build for Android

### Prerequisites
```bash
# Install Android SDK
flutter doctor --android-licenses
```

### Build APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 5️⃣ Build for iOS

### Prerequisites
- macOS with Xcode installed
- Apple Developer account

### Build
```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

---

## 6️⃣ Run in Development Mode

### Web
```bash
flutter run -d chrome
```

### Android (with device/emulator connected)
```bash
flutter run -d android
```

### iOS (on macOS with device/simulator)
```bash
flutter run -d ios
```

---

## Configuration Checklist

Before running, ensure you have:

- [x] `.env` file with R2 credentials
- [x] Firebase project configured
- [x] `google-services.json` (Android)
- [x] `GoogleService-Info.plist` (iOS)
- [x] R2 bucket CORS configured

---

## Environment Variables (.env)

```env
R2_ENDPOINT=https://<account_id>.r2.cloudflarestorage.com
R2_ACCESS_KEY_ID=<your_access_key>
R2_SECRET_ACCESS_KEY=<your_secret_key>
R2_BUCKET_NAME=<your_bucket_name>
R2_REGION=auto
```

---

## Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication → Email/Password
3. Add your deployment domain to authorized domains
4. Download config files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`

---

## R2 CORS Configuration

In your R2 bucket settings, add:

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

---

## Troubleshooting

### "Flutter command not found"
```bash
export PATH="/tmp/flutter/bin:$PATH"
# Or install Flutter: https://flutter.dev/docs/get-started/install
```

### "Android SDK not found"
```bash
flutter doctor
# Follow instructions to install Android Studio
```

### "Firebase initialization failed"
- Check `lib/firebase_options.dart` has correct values
- Verify `google-services.json` / `GoogleService-Info.plist` are in place

### "R2 connection failed"
- Verify `.env` credentials are correct
- Check R2 bucket CORS is configured
- Ensure bucket is accessible

---

## Features

✅ Firebase Authentication  
✅ File & Folder Management  
✅ Upload with Progress  
✅ Download & Share Links  
✅ Bulk Operations  
✅ Search & Filter  
✅ Dark Theme (Orange Accent)  
✅ Responsive Design  
✅ Pull-to-Refresh  
✅ Shimmer Loading  

---

## Support

- **Flutter Version:** 3.41.3
- **Dart Version:** 3.11.1
- **Platforms:** Web, Android, iOS, macOS, Linux, Windows

---

**Happy Building! 🎉**
