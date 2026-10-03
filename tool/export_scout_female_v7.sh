#!/usr/bin/env bash
set -euo pipefail
questwell_root="$(cd "$(dirname "$0")/.." && pwd)"
questwell_temp="$(mktemp -d)"
trap 'rm -rf "$questwell_temp"' EXIT
questwell_assets="$questwell_root/assets/images/questwell/avatar"
# One global registration; never warp or replace the body.
convert "$questwell_root/tool/art_assets/scout_female_v7/robe_fitted_source.png" \
  -resize 195x260 -background none -gravity northwest -splice 19x44 \
  -extent 240x320 "$questwell_temp/front.png"
# A cloth-only depth split: these are exactly the same generated pixels.
convert -size 240x320 xc:none -fill white \
  -draw 'rectangle 61,164 88,174 rectangle 152,164 177,174' "$questwell_temp/cuffs.png"
convert "$questwell_temp/front.png" "$questwell_temp/cuffs.png" \
  -compose DstOut -composite -define webp:lossless=true "$questwell_assets/scout_robe_female_v7.webp"
convert "$questwell_temp/front.png" "$questwell_temp/cuffs.png" \
  -compose DstIn -composite -define webp:lossless=true "$questwell_assets/scout_robe_cuff_front_female_v7.webp"
# Preserve the existing continuous rear cloth, lengthened to the new hem.
convert "$questwell_assets/scout_robe_rear_female_v6.webp" \
  -resize 240x344! -crop 240x320+0+8 +repage -define webp:lossless=true \
  "$questwell_assets/scout_robe_rear_female_v7.webp"
