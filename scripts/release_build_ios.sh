#!/usr/bin/env bash

readonly SCRIPTS_DIR="$(dirname "$0")"

flutter clean && \
flutter pub get && \
bash "$SCRIPTS_DIR"/format.sh && \
flutter analyze && \
flutter build ipa --split-debug-info=build/app/outputs/symbols --obfuscate
