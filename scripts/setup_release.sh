#!/usr/bin/env bash
set -e

# Setup script for TAT production releases
# Clones the private config repo and copies signing keys and Firebase config files
# Required for building release APKs/IPAs for App Store and Play Store

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_DIR="$(mktemp -d)"
CONFIG_REPO="git@github.com:NEO-TAT/RealGoogleServicesConfig.git"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo_step() { echo -e "${GREEN}==>${NC} $1"; }
echo_error() { echo -e "${RED}Error:${NC} $1"; }

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo_step "Cloning release config repo..."
git clone --depth 1 "$CONFIG_REPO" "$TEMP_DIR/config" 2>/dev/null || {
    echo_error "Failed to clone config repo. Do you have access?"
    exit 1
}

CONFIG_DIR="$TEMP_DIR/config"

# Android: signing key and Firebase config
echo_step "Copying Android files..."
cp "$CONFIG_DIR/tat.jks" "$PROJECT_DIR/android/tat.jks"
mkdir -p "$PROJECT_DIR/android/app/src/real"
cp "$CONFIG_DIR/google-services.json" "$PROJECT_DIR/android/app/src/real/google-services.json"
cp "$CONFIG_DIR/key.properties" "$PROJECT_DIR/android/key.properties"
echo "  ✓ android/tat.jks (Play Store signing key)"
echo "  ✓ android/app/src/real/google-services.json"
echo "  ✓ android/key.properties"

# iOS: Firebase config
echo_step "Copying iOS files..."
mkdir -p "$PROJECT_DIR/ios/GoogleServices/real"
cp "$CONFIG_DIR/GoogleService-Info.plist" "$PROJECT_DIR/ios/GoogleServices/real/GoogleService-Info.plist"
cp "$CONFIG_DIR/firebase_app_id_file.json" "$PROJECT_DIR/ios/GoogleServices/real/firebase_app_id_file.json"
echo "  ✓ ios/GoogleServices/real/GoogleService-Info.plist"
echo "  ✓ ios/GoogleServices/real/firebase_app_id_file.json"

echo_step "Setup complete!"
