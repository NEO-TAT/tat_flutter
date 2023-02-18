#!/usr/bin/env bash

flutter pub run intl_utils:generate && bash "$(dirname "$0")"/format.sh
