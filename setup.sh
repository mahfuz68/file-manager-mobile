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

# 1. Install Flutter
echo -e "${GREEN}[1/4] Checking Flutter installation...${NC}"
if command_exists flutter; then
    echo "✓ Flutter is already installed: $(flutter --version | head -n 1)"
else
    echo "Installing Flutter..."
    cd ~
    
    # Download Flutter
    echo "Downloading Flutter SDK..."
    wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
    
    # Extract Flutter
    echo "Extracting Flutter..."
    tar xf flutter_linux_3.24.0-stable.tar.xz
    rm flutter_linux_3.24.0-stable.tar.xz
    
    # Add to PATH
    export PATH="$PATH:$HOME/flutter/bin"
    
    # Add to bashrc if not already present
    if ! grep -q 'flutter/bin' ~/.bashrc; then
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
if command_exists java && java -version 2>&1 | grep -q "17"; then
    echo "✓ Java 17 is already installed"
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
if [ -d "$HOME/android-sdk" ]; then
    echo "✓ Android SDK is already installed"
else
    echo "Installing Android SDK..."
    mkdir -p $HOME/android-sdk/cmdline-tools
    cd $HOME/android-sdk/cmdline-tools
    
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    unzip -q commandlinetools-linux-9477386_latest.zip
    mv cmdline-tools latest
    rm commandlinetools-linux-9477386_latest.zip
    
    # Set environment variables
    export ANDROID_HOME=$HOME/android-sdk
    echo 'export ANDROID_HOME=$HOME/android-sdk' >> ~/.bashrc
    echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools' >> ~/.bashrc
    export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
    
    # Accept licenses and install required packages
    yes | sdkmanager --licenses
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
    
    # Configure Flutter to use Android SDK
    flutter config --android-sdk $ANDROID_HOME
    
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
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.bashrc"
echo "  2. Run: make build-apk"
echo ""
