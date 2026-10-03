#!/usr/bin/env bash
set -euo pipefail
questwell_root="$(cd "$(dirname "$0")/.." && pwd)"
questwell_temp="$(mktemp -d)"
trap 'rm -rf "$questwell_temp"' EXIT
questwell_class="$questwell_root/assets/images/questwell/avatar/classes/alchemist"
convert "$questwell_class/alchemist_robe_female_v6.webp" \
  "$questwell_class/alchemist_robe_cuff_front_female_v6.webp" -composite "$questwell_temp/original.png"
# Register the right-cuff imagegen edit to the unchanged outer wrist edge.
convert "$questwell_root/tool/art_assets/alchemist_female_v7/right_cuff_source.png" \
  -resize 195x260 -background none -gravity northwest -splice 15x44 -extent 240x320 \
  -crop 236x320+4+0 +repage -background none -gravity northwest -extent 240x320 \
  "$questwell_temp/edit.png"
convert -size 240x320 xc:black -fill white \
  -draw 'polygon 162,154 159,157 155,161 153,166 153,172 164,172 164,161 163,156' "$questwell_temp/edit-mask.png"
convert "$questwell_temp/original.png" "$questwell_temp/edit.png" "$questwell_temp/edit-mask.png" \
  -compose Src -composite "$questwell_temp/front.png"
convert -size 240x320 xc:none -fill white \
  -draw 'rectangle 60,163 89,174 rectangle 150,163 177,174' "$questwell_temp/cuffs.png"
convert "$questwell_temp/front.png" "$questwell_temp/cuffs.png" -compose DstOut -composite \
  -define webp:lossless=true "$questwell_class/alchemist_robe_female_v7.webp"
convert "$questwell_temp/front.png" "$questwell_temp/cuffs.png" -compose DstIn -composite \
  -define webp:lossless=true "$questwell_class/alchemist_robe_cuff_front_female_v7.webp"
cp "$questwell_class/alchemist_robe_rear_female_v6.webp" "$questwell_class/alchemist_robe_rear_female_v7.webp"
