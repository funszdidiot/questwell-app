#!/usr/bin/env bash
set -euo pipefail
questwell_root="$(cd "$(dirname "$0")/.." && pwd)"
questwell_temp="$(mktemp -d)"
trap 'rm -rf "$questwell_temp"' EXIT
questwell_assets="$questwell_root/assets/images/questwell/avatar"
questwell_source="$questwell_root/tool/art_assets/scout_female_v8"
questwell_template="$questwell_assets/classes/alchemist"
# Imagegen removed only the two breast pockets from a registered chest crop.
convert "$questwell_source/chest_without_pockets.png" -resize 380x190! \
  -background none -gravity northwest -splice 370x245 -extent 1086x1448 "$questwell_temp/chest.png"
convert -size 1086x1448 xc:black -fill white \
  -draw 'rectangle 433,304 477,353 rectangle 639,304 688,353' -blur 0x3 "$questwell_temp/chest-mask.png"
convert "$questwell_source/robe_source.png" "$questwell_temp/chest.png" "$questwell_temp/chest-mask.png" \
  -compose Src -composite -resize 205x274! -background none -gravity northwest \
  -splice 13x42 -extent 240x320 "$questwell_temp/texture.png"
# These landmarks register RGB surface art only. The silhouette is copied
# unchanged from the locked Alchemist masks below, including both widened cuffs.
questwell_landmarks="$(cat "$questwell_source/texture_landmarks.txt")"
convert "$questwell_temp/texture.png" -virtual-pixel transparent \
  -distort Shepards "$questwell_landmarks" "$questwell_temp/registered.png"
# Edge-color padding prevents transparent generator margins from darkening
# the exact template boundary. The original opaque surface detail stays above it.
convert "$questwell_temp/registered.png" -alpha extract -threshold 50% \
  -morphology EdgeIn Diamond:1 "$questwell_temp/edge.png"
convert "$questwell_temp/registered.png" "$questwell_temp/edge.png" \
  -compose CopyOpacity -composite -depth 8 txt:- |
  awk -F '[:,() ]+' '$1 ~ /^[0-9]+$/ && ($6+0) > 128 { print $1 "," $2 " rgb(" $3 "," $4 "," $5 ")" }' > "$questwell_temp/colors.txt"
questwell_colors="$(cat "$questwell_temp/colors.txt")"
convert -size 240x320 xc:none -sparse-color Voronoi "$questwell_colors" "$questwell_temp/bleed.png"
convert "$questwell_temp/bleed.png" "$questwell_temp/registered.png" \
  -compose Over -composite -alpha off "$questwell_temp/rgb.png"
for questwell_part in robe robe_cuff_front; do
  convert "$questwell_temp/rgb.png" "$questwell_template/alchemist_${questwell_part}_female_v7.webp" \
    -compose CopyOpacity -composite -define webp:lossless=true \
    "$questwell_assets/scout_${questwell_part}_female_v8.webp"
done
# Same rear geometry as Alchemist; retain Scout's olive lining surface.
convert "$questwell_assets/scout_robe_rear_female_v7.webp" -alpha off \
  "$questwell_template/alchemist_robe_rear_female_v7.webp" -compose CopyOpacity -composite \
  -define webp:lossless=true "$questwell_assets/scout_robe_rear_female_v8.webp"
