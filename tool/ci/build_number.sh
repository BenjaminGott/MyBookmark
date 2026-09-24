#!/usr/bin/env bash
# Numéro de version Android (versionCode) : les minutes écoulées depuis le
# 1er janvier 2026. Google Play refuse deux fois le même numéro, toutes pistes
# confondues ; celui-ci augmente à chaque compilation, que ce soit sur `dev`
# ou sur `main`, sans rien avoir à modifier dans pubspec.yaml.
set -euo pipefail
echo $(( ($(date -u +%s) - $(date -u -d '2026-01-01' +%s)) / 60 ))
