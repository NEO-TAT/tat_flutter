#!/bin/bash
set -e

# iOS Build Script for Xcode 16+ compatibility
# Patches Flutter plugins that have non-modular header issues and iOS 18 incompatibilities

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DERIVED_DATA="/tmp/tat-derived-data"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_step() {
    echo -e "${GREEN}==>${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

echo_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Check Xcode version
check_xcode() {
    echo_step "Checking Xcode version..."
    XCODE_VERSION=$(xcodebuild -version | head -1)
    echo "  $XCODE_VERSION"

    if [[ ! "$XCODE_VERSION" =~ "Xcode 16" ]]; then
        echo_warn "Expected Xcode 16.x, got: $XCODE_VERSION"
        echo "  Run: sudo xcode-select -s \"/Applications/Xcode 16.app/Contents/Developer\""
    fi
}

# Patch Firebase Crashlytics
patch_firebase_crashlytics() {
    local plugin_dir="$HOME/.pub-cache/hosted/pub.dev/firebase_crashlytics-3.4.1/ios/Classes"

    if [[ ! -d "$plugin_dir" ]]; then
        echo_warn "firebase_crashlytics-3.4.1 not found, skipping patch"
        return
    fi

    echo_step "Patching firebase_crashlytics..."

    for file in "$plugin_dir/Crashlytics_Platform.h" \
                "$plugin_dir/ExceptionModel_Platform.h" \
                "$plugin_dir/FLTFirebaseCrashlyticsPlugin.m"; do
        if [[ -f "$file" ]] && grep -q '#import <Firebase/Firebase.h>' "$file"; then
            sed -i '' 's/#import <Firebase\/Firebase.h>/@import FirebaseCrashlytics;/' "$file"
            echo "  Patched: $(basename "$file")"
        fi
    done
}

# Patch Firebase Messaging
patch_firebase_messaging() {
    local plugin_dir="$HOME/.pub-cache/hosted/pub.dev/firebase_messaging-14.7.1/ios/Classes"

    if [[ ! -d "$plugin_dir" ]]; then
        echo_warn "firebase_messaging-14.7.1 not found, skipping patch"
        return
    fi

    echo_step "Patching firebase_messaging..."

    # Patch header
    local header="$plugin_dir/FLTFirebaseMessagingPlugin.h"
    if [[ -f "$header" ]] && grep -q '#import <Firebase/Firebase.h>' "$header"; then
        sed -i '' 's/#import <Firebase\/Firebase.h>/@import FirebaseMessaging;/' "$header"
        echo "  Patched: $(basename "$header")"
    fi

    # Add FirebaseAuth import to .m file if not already present
    local impl="$plugin_dir/FLTFirebaseMessagingPlugin.m"
    if [[ -f "$impl" ]] && ! grep -q '@import FirebaseAuth;' "$impl"; then
        sed -i '' '10a\
#if __has_include(<FirebaseAuth/FirebaseAuth.h>)\
@import FirebaseAuth;\
#endif
' "$impl"
        echo "  Added FirebaseAuth import to: $(basename "$impl")"
    fi
}

# Patch Firebase Auth
patch_firebase_auth() {
    local plugin_dir="$HOME/.pub-cache/hosted/pub.dev/firebase_auth-4.11.1/ios/Classes"

    if [[ ! -d "$plugin_dir" ]]; then
        echo_warn "firebase_auth-4.11.1 not found, skipping patch"
        return
    fi

    echo_step "Patching firebase_auth..."

    for file in "$plugin_dir/FLTFirebaseAuthPlugin.m" \
                "$plugin_dir/Public/FLTFirebaseAuthPlugin.h" \
                "$plugin_dir/Private/PigeonParser.h" \
                "$plugin_dir/Private/FLTAuthStateChannelStreamHandler.h" \
                "$plugin_dir/Private/FLTIdTokenChannelStreamHandler.h" \
                "$plugin_dir/Private/FLTPhoneNumberVerificationStreamHandler.h"; do
        if [[ -f "$file" ]] && grep -q '#import <Firebase/Firebase.h>' "$file"; then
            sed -i '' 's/#import <Firebase\/Firebase.h>/@import FirebaseAuth;/' "$file"
            echo "  Patched: $(basename "$file")"
        fi
    done
}

# Patch flutter_inappwebview for iOS 18
patch_flutter_inappwebview() {
    local swift_file="$HOME/.pub-cache/hosted/pub.dev/flutter_inappwebview-5.8.0/ios/Classes/InAppWebView/InAppWebView.swift"

    if [[ ! -f "$swift_file" ]]; then
        echo_warn "flutter_inappwebview-5.8.0 not found, skipping patch"
        return
    fi

    echo_step "Patching flutter_inappwebview for iOS 18..."

    if grep -q 'public override func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil)' "$swift_file"; then
        sed -i '' 's/public override func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil)/open override func evaluateJavaScript(_ javaScriptString: String, completionHandler: (@MainActor (Any?, Error?) -> Void)? = nil)/' "$swift_file"
        echo "  Patched: InAppWebView.swift"
    else
        echo "  Already patched or different version"
    fi
}

# Build iOS app
build_ios() {
    local config="${1:-Debug-beta}"
    local sdk="${2:-iphonesimulator}"
    local destination="${3:-platform=iOS Simulator,name=iPhone 16 Pro}"

    echo_step "Building iOS app..."
    echo "  Configuration: $config"
    echo "  SDK: $sdk"
    echo "  DerivedData: $DERIVED_DATA"

    cd "$PROJECT_DIR/ios"

    xcodebuild -workspace Runner.xcworkspace \
        -scheme beta \
        -configuration "$config" \
        -sdk "$sdk" \
        -destination "$destination" \
        -derivedDataPath "$DERIVED_DATA" \
        build

    echo_step "Build succeeded!"
    echo "  App location: $DERIVED_DATA/Build/Products/$config-${sdk}/Runner.app"
}

# Install to simulator
install_simulator() {
    local device_id="${1:-}"
    local config="${2:-Debug-beta}"

    if [[ -z "$device_id" ]]; then
        # Try to find a booted simulator
        device_id=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -oE '[A-F0-9-]{36}')
    fi

    if [[ -z "$device_id" ]]; then
        echo_error "No booted simulator found. Boot one first or provide device ID."
        return 1
    fi

    local app_path="$DERIVED_DATA/Build/Products/$config-iphonesimulator/Runner.app"

    if [[ ! -d "$app_path" ]]; then
        echo_error "App not found at: $app_path"
        echo "  Run the build first: $0 build"
        return 1
    fi

    echo_step "Installing to simulator $device_id..."
    xcrun simctl install "$device_id" "$app_path"
    echo "  Installed successfully"
}

# Launch on simulator
launch_simulator() {
    local device_id="${1:-}"

    if [[ -z "$device_id" ]]; then
        device_id=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -oE '[A-F0-9-]{36}')
    fi

    if [[ -z "$device_id" ]]; then
        echo_error "No booted simulator found."
        return 1
    fi

    echo_step "Launching app on simulator..."
    xcrun simctl launch "$device_id" com.npc.tatFlutter
    echo "  App launched"
}

# Clean build artifacts
clean() {
    echo_step "Cleaning build artifacts..."
    rm -rf "$DERIVED_DATA"
    rm -rf "$PROJECT_DIR/ios/build"
    rm -rf "$PROJECT_DIR/build/ios"
    echo "  Cleaned"
}

# Show help
show_help() {
    echo "iOS Build Script for Xcode 16+ compatibility"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  patch       Apply all patches to pub-cache plugins"
    echo "  build       Build the iOS app (applies patches first)"
    echo "  install     Install built app to simulator"
    echo "  launch      Launch app on simulator"
    echo "  run         Build, install, and launch (full workflow)"
    echo "  clean       Remove build artifacts"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 patch                    # Just apply patches"
    echo "  $0 build                    # Patch and build"
    echo "  $0 run                      # Full workflow"
    echo "  $0 install <device-id>      # Install to specific simulator"
}

# Main
case "${1:-help}" in
    patch)
        check_xcode
        patch_firebase_crashlytics
        patch_firebase_messaging
        patch_firebase_auth
        patch_flutter_inappwebview
        echo_step "All patches applied!"
        ;;
    build)
        check_xcode
        patch_firebase_crashlytics
        patch_firebase_messaging
        patch_firebase_auth
        patch_flutter_inappwebview
        build_ios "${2:-Debug-beta}" "${3:-iphonesimulator}"
        ;;
    install)
        install_simulator "$2" "${3:-Debug-beta}"
        ;;
    launch)
        launch_simulator "$2"
        ;;
    run)
        check_xcode
        patch_firebase_crashlytics
        patch_firebase_messaging
        patch_firebase_auth
        patch_flutter_inappwebview
        build_ios "Debug-beta" "iphonesimulator"
        install_simulator "$2"
        launch_simulator "$2"
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
