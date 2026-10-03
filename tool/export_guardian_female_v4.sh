#!/usr/bin/env bash
set -euo pipefail
questwell_root="$(cd "$(dirname "$0")/.." && pwd)"
questwell_temp="$(mktemp -d)"
trap 'rm -rf "$questwell_temp"' EXIT
questwell_assets="$questwell_root/assets/images/questwell/avatar/classes"
questwell_source="$questwell_root/tool/art_assets/guardian_female_v4"
# Register only the generated surface. Locked silhouettes are copied below.
convert "$questwell_source/robe_final_no_inner_flaps.png" -resize 230x320! \
  -background none -gravity northwest -splice 1x3 -extent 240x320 "$questwell_temp/texture.png"
questwell_landmarks="$(cat "$questwell_source/texture_landmarks.txt")"
convert "$questwell_temp/texture.png" -virtual-pixel transparent \
  -distort Shepards "$questwell_landmarks" "$questwell_temp/registered.png"
# Extend RGB edge colors beneath the immutable alpha to avoid dark seams.
pad_rgb() {
  convert "$1" -alpha extract -threshold 50% -morphology EdgeIn Diamond:1 "$questwell_temp/edge.png"
  convert "$1" "$questwell_temp/edge.png" -compose CopyOpacity -composite -depth 8 txt:- |
    awk -F '[:,() ]+' '$1 ~ /^[0-9]+$/ && ($6+0) > 128 { print $1 "," $2 " rgb(" $3 "," $4 "," $5 ")" }' > "$questwell_temp/colors.txt"
  questwell_colors="$(cat "$questwell_temp/colors.txt")"
  convert -size 240x320 xc:none -sparse-color Voronoi "$questwell_colors" "$questwell_temp/bleed.png"
  convert "$questwell_temp/bleed.png" "$1" -compose Over -composite -alpha off "$2"
}
pad_rgb "$questwell_temp/registered.png" "$questwell_temp/rgb.png"
for questwell_part in robe robe_cuff_front; do
  convert "$questwell_temp/rgb.png" "$questwell_assets/alchemist/alchemist_${questwell_part}_female_v7.webp" \
    -compose CopyOpacity -composite -define webp:lossless=true \
    "$questwell_assets/guardian/guardian_${questwell_part}_female_v4.webp"
done
# Register the continuous central cloth texture to the narrow locked rear panel.
# The crop excludes the old robe's outer transparent fringe.
convert "$questwell_assets/guardian/guardian_rear_female_wrap_v1.webp" \
  -crop 32x100+104+151 +repage -resize 60x150! -background none \
  -gravity northwest -splice 90x130 -extent 240x320 "$questwell_temp/rear-rgb.png"
convert "$questwell_temp/rear-rgb.png" "$questwell_assets/alchemist/alchemist_robe_rear_female_v7.webp" \
  -compose CopyOpacity -composite -define webp:lossless=true \
  "$questwell_assets/guardian/guardian_robe_rear_female_v4.webp"
