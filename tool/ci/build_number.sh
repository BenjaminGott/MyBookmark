#!/usr/bin/env bash
# Numéro de version (versionCode Android, CFBundleVersion iOS) : les minutes
# écoulées depuis le 1er janvier 2026. Les boutiques refusent deux fois le même
# numéro ; celui-ci augmente à chaque compilation, sur `dev` comme sur `main`,
# sans rien avoir à modifier dans pubspec.yaml.
#
# 1767225600 = 2026-01-01T00:00:00Z, écrit en dur : `date -d` n'existe pas
# sur macOS (Codemagic).
set -euo pipefail
echo $(( ($(date -u +%s) - 1767225600) / 60 ))
