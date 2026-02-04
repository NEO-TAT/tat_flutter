#!/usr/bin/env bash

# A script that formats the project.

dart fix --apply && dart format --fix -l 120 .
