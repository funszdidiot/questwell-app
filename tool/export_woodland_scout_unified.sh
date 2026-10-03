#!/usr/bin/env bash
set -euo pipefail
questwell_root="$(cd "$(dirname "$0")/.." && pwd)"
convert "$questwell_root/tool/art_assets/woodland_scout_unified/female_inward_sleeves_source.png" \
  -resize 210x280 -background none -gravity northwest -splice 7x36 \
  -extent 240x320 -define webp:lossless=true \
  "$questwell_root/assets/images/questwell/avatar/woodland_scout_unified_female_v11.webp"
