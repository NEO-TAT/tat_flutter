#!/usr/bin/env bash

readonly SCRIPTS_DIR="$(dirname "$0")"

bash "$SCRIPTS_DIR"/format.sh && \
bash "$SCRIPTS_DIR"/patch_ios.sh && \
flutter analyze && \
flutter build ipa -v --release --flavor real \
  --export-method app-store \
  --null-assertions \
  --split-debug-info=build/app/outputs/symbols --obfuscate
