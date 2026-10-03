#!/usr/bin/env bash
set -euo pipefail
questwell_root="$(cd "$(dirname "$0")/.." && pwd)"
questwell_temp="$(mktemp -d)"
trap 'rm -rf "$questwell_temp"' EXIT
questwell_assets="$questwell_root/assets/images/questwell/avatar"
questwell_class="$questwell_assets/classes/alchemist"
# One cloth registration on the frozen 240x320 female canvas.
convert "$questwell_root/tool/art_assets/alchemist_female_v5/robe_refined_source.png" \
  -resize 195x260 -background none -gravity northwest -splice 15x44 \
  -extent 240x320 "$questwell_temp/front.png"
# Keep the generated, attached wrist hems above held equipment.
convert -size 240x320 xc:none -fill white \
  -draw 'rectangle 60,163 89,174 rectangle 150,163 177,174' "$questwell_temp/cuffs.png"
convert "$questwell_temp/front.png" "$questwell_temp/cuffs.png" \
  -compose DstOut -composite -define webp:lossless=true "$questwell_class/alchemist_robe_female_v5.webp"
convert "$questwell_temp/front.png" "$questwell_temp/cuffs.png" \
  -compose DstIn -composite -define webp:lossless=true "$questwell_class/alchemist_robe_cuff_front_female_v5.webp"
# Reuse existing Alchemist lining art. The accepted narrow rear-cloth mask
# limits it to the same body registration; the body occludes its upper edge.
convert "$questwell_class/alchemist_rear_female_wrap_v1.webp" \
  -resize 240x378! -crop 240x320+0+31 +repage \
  "$questwell_assets/scout_robe_rear_female_v7.webp" -compose DstIn -composite \
  -define webp:lossless=true "$questwell_class/alchemist_robe_rear_female_v5.webp"
