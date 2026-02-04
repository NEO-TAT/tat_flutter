#!/usr/bin/env bash

flutter pub run build_runner build --delete-conflicting-outputs && bash "$(dirname "$0")"/format.sh
