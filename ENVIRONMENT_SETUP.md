# Environment Setup Guide

This document describes how to set up the Flutter Android build environment.

## Prerequisites

- Linux operating system (Ubuntu 24.04.3 LTS)
- Git
- wget
- unzip
- Java JDK (for Android build tools)

## Step-by-Step Setup

### 1. Install Flutter SDK

```bash
cd /home/codespace
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:/home/codespace/flutter/bin"
```

### 2. Install Android Command-Line Tools

```bash
mkdir -p /home/codespace/android/cmdline-tools
cd /home/codespace/android/cmdline-tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip -q cmdline-tools.zip
mv cmdline-tools latest
rm cmdline-tools.zip
```

### 3. Set Environment Variables

Add these to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
export ANDROID_HOME=/home/codespace/android
export ANDROID_SDK_ROOT=/home/codespace/android
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
export PATH="$PATH:/home/codespace/flutter/bin"
```

### 4. Accept Android SDK Licenses

```bash
yes | sdkmanager --licenses
```

### 5. Install Required Android SDK Components

```bash
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### 6. Configure Flutter with Android SDK

```bash
flutter config --android-sdk $ANDROID_HOME
```

### 7. Verify Setup

```bash
flutter doctor
```

Expected output should show:
- ✓ Flutter (Channel stable)
- ✓ Android toolchain
- ✓ Android SDK

### 8. Build the App

```bash
cd /workspaces/file-manager-mobile
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Quick Setup Script

Run all commands at once:

```bash
#!/bin/bash

# Install Flutter
cd /home/codespace
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:/home/codespace/flutter/bin"

# Install Android SDK
mkdir -p /home/codespace/android/cmdline-tools
cd /home/codespace/android/cmdline-tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip -q cmdline-tools.zip
mv cmdline-tools latest
rm cmdline-tools.zip

# Set environment
export ANDROID_HOME=/home/codespace/android
export ANDROID_SDK_ROOT=/home/codespace/android
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# Accept licenses and install components
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Configure Flutter
flutter config --android-sdk $ANDROID_HOME

# Build the app
cd /workspaces/file-manager-mobile
flutter build apk --release
```

## Environment Variables Summary

| Variable | Value |
|----------|-------|
| `ANDROID_HOME` | `/home/codespace/android` |
| `ANDROID_SDK_ROOT` | `/home/codespace/android` |
| `PATH` (additional) | `$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/home/codespace/flutter/bin` |

## Installed Components

- Flutter SDK: 3.41.3 (stable channel)
- Android SDK Build-Tools: 34.0.0, 35.0.0
- Android SDK Platform: 34, 36
- Android SDK Platform-Tools
- Android NDK: 28.2.13676358
- CMake: 3.22.1

## Troubleshooting

### Flutter not found
Ensure Flutter is in your PATH:
```bash
export PATH="$PATH:/home/codespace/flutter/bin"
```

### Android SDK not found
Ensure ANDROID_HOME is set:
```bash
export ANDROID_HOME=/home/codespace/android
flutter config --android-sdk $ANDROID_HOME
```

### License not accepted
```bash
sdkmanager --licenses
```
