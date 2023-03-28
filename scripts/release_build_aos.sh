#!/usr/bin/env bash

readonly SCRIPTS_DIR="$(dirname "$0")"

flutter pub get && \
bash "$SCRIPTS_DIR"/format.sh && \
flutter analyze && \
flutter build appbundle -v --release --flavor real \
  --deferred-components \
  --validate-deferred-components \
  --null-assertions \
  --no-track-widget-creation \
  --split-debug-info=build/app/outputs/symbols --obfuscate
