.PHONY: help setup install-deps clean build-apk build-apk-debug build-apk-split build-apk-all build-ios run test

help:
	@echo "Flutter R2 File Manager - Build Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          - Install all required tools (Flutter, Java, Android SDK)"
	@echo "  make install-deps   - Install Flutter dependencies"
	@echo ""
	@echo "Build:"
	@echo "  make build-apk      - Build release APK for Android (universal)"
	@echo "  make build-apk-debug - Build debug APK for Android"
	@echo "  make build-apk-split - Build split APKs per architecture (arm64-v8a, armeabi-v7a, x86_64)"
	@echo "  make build-apk-all  - Build both universal and split APKs"
	@echo "  make build-ios      - Build iOS app (macOS only)"
	@echo ""
	@echo "Development:"
	@echo "  make run            - Run app in debug mode"
	@echo "  make test           - Run tests"
	@echo "  make clean          - Clean build artifacts"

setup:
	@echo "Installing required tools..."
	@chmod +x setup.sh
	@./setup.sh

install-deps:
	@echo "Installing Flutter dependencies..."
	@flutter pub get

clean:
	@echo "Cleaning build artifacts..."
	@flutter clean
	@rm -rf build/

build-apk: install-deps
	@echo "Building universal release APK..."
	@export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 && \
	export PATH=$$JAVA_HOME/bin:$$PATH && \
	flutter build apk --release
	@echo ""
	@echo "✓ Universal APK built successfully!"
	@echo "Location: build/app/outputs/flutter-apk/app-release.apk"

build-apk-debug: install-deps
	@echo "Building debug APK..."
	@export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 && \
	export PATH=$$JAVA_HOME/bin:$$PATH && \
	flutter build apk --debug
	@echo ""
	@echo "✓ Debug APK built successfully!"
	@echo "Location: build/app/outputs/flutter-apk/app-debug.apk"

build-apk-split: install-deps
	@echo "Building split APKs per architecture..."
	@export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 && \
	export PATH=$$JAVA_HOME/bin:$$PATH && \
	flutter build apk --release --split-per-abi
	@echo ""
	@echo "✓ Split APKs built successfully!"
	@echo "Locations:"
	@echo "  - arm64-v8a:    build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
	@echo "  - armeabi-v7a:  build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
	@echo "  - x86_64:       build/app/outputs/flutter-apk/app-x86_64-release.apk"

build-apk-all: install-deps
	@echo "Building all APK variants..."
	@export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 && \
	export PATH=$$JAVA_HOME/bin:$$PATH && \
	flutter build apk --release && \
	flutter build apk --release --split-per-abi
	@echo ""
	@echo "✓ All APKs built successfully!"
	@echo ""
	@echo "Universal APK:"
	@echo "  - build/app/outputs/flutter-apk/app-release.apk"
	@echo ""
	@echo "Split APKs:"
	@echo "  - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
	@echo "  - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
	@echo "  - build/app/outputs/flutter-apk/app-x86_64-release.apk"

build-ios: install-deps
	@echo "Building iOS app..."
	@flutter build ios --release
	@echo ""
	@echo "✓ iOS app built successfully!"

run: install-deps
	@echo "Running app in debug mode..."
	@flutter run

test:
	@echo "Running tests..."
	@flutter test