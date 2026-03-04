#!/bin/bash

set -e

echo "=========================================="
echo "Flutter R2 File Manager - Setup Script"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${YELLOW}Warning: This script is designed for Linux. Some steps may not work on other systems.${NC}"
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Determine installation directory (use HOME if not in codespace)
INSTALL_DIR="${HOME}"
if [[ -d "/home/codespace" ]]; then
    INSTALL_DIR="/home/codespace"
fi

# Android SDK location
ANDROID_HOME="${INSTALL_DIR}/android"
FLUTTER_DIR="${INSTALL_DIR}/flutter"

# 1. Install Flutter SDK
echo -e "${GREEN}[1/4] Checking Flutter installation...${NC}"
if command_exists flutter; then
    echo "✓ Flutter is already installed: $(flutter --version | head -n 1)"
else
    echo "Installing Flutter SDK..."
    cd "${INSTALL_DIR}"

    # Clone Flutter (stable channel, shallow clone for faster download)
    echo "Cloning Flutter SDK from GitHub..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1

    # Add to PATH
    export PATH="$PATH:${FLUTTER_DIR}/bin"

    # Add to bashrc if not already present
    if ! grep -q 'flutter/bin' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
    fi

    # Run flutter doctor to download Dart SDK and other dependencies
    echo "Initializing Flutter..."
    flutter doctor

    echo "✓ Flutter installed successfully"
fi

# 2. Install Java 17
echo ""
echo -e "${GREEN}[2/4] Checking Java installation...${NC}"
if command_exists java && java -version 2>&1 | grep -q "17\|21"; then
    echo "✓ Java $(java -version 2>&1 | grep -oP '\d+' | head -n 1) is already installed"
else
    echo "Installing OpenJDK 17..."
    sudo apt-get update -qq
    sudo apt-get install -y openjdk-17-jdk

    # Set JAVA_HOME
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc

    echo "✓ Java 17 installed successfully"
fi

# 3. Install Android SDK
echo ""
echo -e "${GREEN}[3/4] Checking Android SDK installation...${NC}"
if [ -d "${ANDROID_HOME}" ] && [ -d "${ANDROID_HOME}/cmdline-tools/latest" ]; then
    echo "✓ Android SDK is already installed"
    export ANDROID_HOME="${ANDROID_HOME}"
    export ANDROID_SDK_ROOT="${ANDROID_HOME}"
    export PATH="$PATH:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"
else
    echo "Installing Android SDK..."
    mkdir -p "${ANDROID_HOME}/cmdline-tools"
    cd "${ANDROID_HOME}/cmdline-tools"

    # Download latest command-line tools
    echo "Downloading Android command-line tools..."
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip

    # Extract and organize
    echo "Extracting Android command-line tools..."
    unzip -q cmdline-tools.zip
    mv cmdline-tools latest
    rm cmdline-tools.zip

    # Set environment variables
    export ANDROID_HOME="${ANDROID_HOME}"
    export ANDROID_SDK_ROOT="${ANDROID_HOME}"
    export PATH="$PATH:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

    # Add to bashrc if not already present
    if ! grep -q 'ANDROID_HOME' ~/.bashrc 2>/dev/null; then
        echo "export ANDROID_HOME=\$HOME/android" >> ~/.bashrc
        echo "export ANDROID_SDK_ROOT=\$HOME/android" >> ~/.bashrc
        echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"' >> ~/.bashrc
    fi

    # Accept licenses and install required packages
    echo "Accepting Android SDK licenses..."
    yes | sdkmanager --licenses

    echo "Installing Android SDK components (platform-tools, platforms;android-34, build-tools;34.0.0)..."
    sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

    # Configure Flutter to use Android SDK
    flutter config --android-sdk "${ANDROID_HOME}"

    echo "✓ Android SDK installed successfully"
fi

# 4. Install Flutter dependencies
echo ""
echo -e "${GREEN}[4/4] Installing Flutter dependencies...${NC}"
cd "$(dirname "$0")"
flutter pub get
echo "✓ Flutter dependencies installed"

# Run Flutter doctor
echo ""
echo -e "${GREEN}Running Flutter doctor...${NC}"
flutter doctor

echo ""
echo -e "${GREEN}=========================================="
echo "Setup completed successfully!"
echo "==========================================${NC}"
echo ""
echo "Environment Variables Summary:"
echo "  ANDROID_HOME: ${ANDROID_HOME}"
echo "  ANDROID_SDK_ROOT: ${ANDROID_HOME}"
echo "  PATH includes: \$ANDROID_HOME/cmdline-tools/latest/bin, \$ANDROID_HOME/platform-tools, \$HOME/flutter/bin"
echo ""
echo "Installed Components:"
echo "  - Flutter SDK (stable channel)"
echo "  - Android SDK Build-Tools: 34.0.0"
echo "  - Android SDK Platform: 34"
echo "  - Android SDK Platform-Tools"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.bashrc"
echo "  2. Run: flutter build apk --release"
echo "  3. The APK will be at: build/app/outputs/flutter-apk/app-release.apk"
echo ""
