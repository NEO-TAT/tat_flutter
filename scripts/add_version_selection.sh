#!/usr/bin/env bash

# A script that adds dart Per-library language version selection comment to all dart files in the same directory.
# This is a preprocessing operation to upgrade the project to nullsafety
# We marked all the old files as using the dart sdk without the nullsafety version,
# then upgraded the full project sdk version to the nullsafety version,
# and then upgraded the old files one by one.

# So, the following will be added to the top of all dart files:

# // TODO: remove sdk version selector after migrating to null-safety.
# // @dart=2.10

# Please ensure that when executing these commands,
# all folders can be fully accessed, which means that we must make sure that when executing these commands,
# we can use recursive search to process all targets one by one.

for f in **/*.dart; do
  origin=$(cat "$f")
  truncate -s 0 "$f"
  printf "// TODO: remove sdk version selector after migrating to null-safety.\n// @dart=2.10\n%s" "$origin" >>"$f"
done
