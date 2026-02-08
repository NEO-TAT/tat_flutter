#!/usr/bin/env bash
set -e

# iOS Patch Script for Xcode 16+ compatibility
# Patches Flutter plugins that have non-modular header issues and iOS 18 incompatibilities
#
# Usage: ./scripts/patch_ios.sh
#
# Run this after `flutter pub get` and before building iOS.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_step() {
    echo -e "${GREEN}==>${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Patch Firebase Crashlytics
patch_firebase_crashlytics() {
    local plugin_dir="$HOME/.pub-cache/hosted/pub.dev/firebase_crashlytics-3.4.1/ios/Classes"

    if [[ ! -d "$plugin_dir" ]]; then
        echo_warn "firebase_crashlytics-3.4.1 not found, skipping"
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
        echo_warn "firebase_messaging-14.7.1 not found, skipping"
        return
    fi

    echo_step "Patching firebase_messaging..."

    local header="$plugin_dir/FLTFirebaseMessagingPlugin.h"
    if [[ -f "$header" ]] && grep -q '#import <Firebase/Firebase.h>' "$header"; then
        sed -i '' 's/#import <Firebase\/Firebase.h>/@import FirebaseMessaging;/' "$header"
        echo "  Patched: $(basename "$header")"
    fi

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
        echo_warn "firebase_auth-4.11.1 not found, skipping"
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

# Add privacy manifest to a plugin's iOS directory and podspec
add_privacy_manifest() {
    local plugin_name="$1"
    local plugin_version="$2"
    local plugin_dir="$HOME/.pub-cache/hosted/pub.dev/${plugin_name}-${plugin_version}/ios"

    if [[ ! -d "$plugin_dir" ]]; then
        echo_warn "${plugin_name}-${plugin_version} not found, skipping"
        return
    fi

    echo_step "Adding privacy manifest to ${plugin_name}..."

    local manifest="$plugin_dir/Classes/PrivacyInfo.xcprivacy"
    if [[ ! -f "$manifest" ]]; then
        cat > "$manifest" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTrackingDomains</key>
	<array/>
	<key>NSPrivacyAccessedAPITypes</key>
	<array/>
	<key>NSPrivacyCollectedDataTypes</key>
	<array/>
	<key>NSPrivacyTracking</key>
	<false/>
</dict>
</plist>
PLIST
        echo "  Created: PrivacyInfo.xcprivacy"
    fi

    local podspec="$plugin_dir/${plugin_name}.podspec"
    if [[ -f "$podspec" ]] && ! grep -q 'resource_bundles' "$podspec"; then
        sed -i '' "/s\.pod_target_xcconfig/i\\
  s.resource_bundles = {'${plugin_name}_privacy' => ['Classes/PrivacyInfo.xcprivacy']}
" "$podspec"
        echo "  Patched: ${plugin_name}.podspec"
    fi
}

# Patch flutter_inappwebview for iOS 18
patch_flutter_inappwebview() {
    local swift_file="$HOME/.pub-cache/hosted/pub.dev/flutter_inappwebview-5.8.0/ios/Classes/InAppWebView/InAppWebView.swift"

    if [[ ! -f "$swift_file" ]]; then
        echo_warn "flutter_inappwebview-5.8.0 not found, skipping"
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

# Main
patch_firebase_crashlytics
patch_firebase_messaging
patch_firebase_auth
patch_flutter_inappwebview
add_privacy_manifest "connectivity_plus" "5.0.2"
add_privacy_manifest "package_info_plus" "3.1.2"
echo_step "All patches applied!"
