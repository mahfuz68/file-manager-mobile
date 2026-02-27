# Flutter R2 File Manager - Build Instructions

## Quick Start

### 1. Install Required Tools
```bash
make setup
```

This will install:
- Flutter SDK
- Java 17 (OpenJDK)
- Android SDK with required components

### 2. Build APK
```bash
make build-apk
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Available Commands

### Setup Commands
- `make setup` - Install all required tools (Flutter, Java, Android SDK)
- `make install-deps` - Install Flutter dependencies only

### Build Commands
- `make build-apk` - Build release APK for Android (universal)
- `make build-apk-debug` - Build debug APK for Android
- `make build-apk-split` - Build split APKs per architecture (smaller size)
- `make build-apk-all` - Build both universal and split APKs
- `make build-ios` - Build iOS app (macOS only)

### Development Commands
- `make run` - Run app in debug mode
- `make test` - Run tests
- `make clean` - Clean build artifacts

## Manual Setup (Alternative)

If you prefer to install tools manually:

### 1. Install Flutter
```bash
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar xf flutter_linux_3.24.0-stable.tar.xz
export PATH="$PATH:$HOME/flutter/bin"
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
```

### 2. Install Java 17
```bash
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
```

### 3. Install Android SDK
```bash
mkdir -p $HOME/android-sdk/cmdline-tools
cd $HOME/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip commandlinetools-linux-9477386_latest.zip
mv cmdline-tools latest
rm commandlinetools-linux-9477386_latest.zip

export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools' >> ~/.bashrc

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
flutter config --android-sdk $ANDROID_HOME
```

### 4. Build APK
```bash
flutter pub get

# Universal APK (works on all devices, larger size ~51MB)
flutter build apk --release

# Split APKs (smaller size, one per architecture)
flutter build apk --release --split-per-abi
```

## APK Types

### Universal APK
- **Size**: ~51MB
- **Compatibility**: Works on all Android devices
- **Use case**: General distribution
- **Command**: `make build-apk`

### Split APKs (Recommended)
- **Size**: ~20MB each
- **Compatibility**: Device-specific (arm64-v8a, armeabi-v7a, x86_64)
- **Use case**: Smaller downloads, faster installation
- **Command**: `make build-apk-split`

**Split APK architectures:**
- `app-arm64-v8a-release.apk` - Modern 64-bit ARM devices (most common)
- `app-armeabi-v7a-release.apk` - Older 32-bit ARM devices
- `app-x86_64-release.apk` - Intel/AMD devices (emulators, tablets)

## System Requirements

- **OS**: Linux (Ubuntu 20.04+ recommended)
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 10GB free space
- **Internet**: Required for downloading dependencies

## Troubleshooting

### Java Version Issues
If you encounter Java version errors, ensure Java 17 is active:
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

### Android SDK License Issues
Accept all licenses:
```bash
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
```

### Flutter Doctor Issues
Run diagnostics:
```bash
flutter doctor -v
```

## Output

The built APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Transfer this file to your Android device and install it.
