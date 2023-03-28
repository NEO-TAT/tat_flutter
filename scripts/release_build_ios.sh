#!/usr/bin/env bash

readonly SCRIPTS_DIR="$(dirname "$0")"

flutter pub get && \
bash "$SCRIPTS_DIR"/format.sh && \
flutter analyze && \
flutter build ipa -v --release --flavor real \
  --export-method app-store \
  --null-assertions \
  --split-debug-info=build/app/outputs/symbols --obfuscate
