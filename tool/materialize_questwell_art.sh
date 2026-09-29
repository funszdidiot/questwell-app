#!/usr/bin/env bash
set -euo pipefail

out_dir="assets/images/questwell/avatar/classes/scholar"
mkdir -p "$out_dir"

materialize() {
  local body="$1"
  local expected="$2"
  local out="$out_dir/scholar_robe_${body}.webp"

  cat     "tool/art_assets/scholar_${body}.b64.1"     "tool/art_assets/scholar_${body}.b64.2"     "tool/art_assets/scholar_${body}.b64.3"     | tr -d '\n\r '     | base64 --decode > "$out"

  echo "${expected}  ${out}" | sha256sum --check --status
  echo "Materialized ${out}"
}

materialize male f7c4346c367abb2ee190d500503cb66a02ff7b745b9e8a02d0a57e1ca9f66683
materialize female 429c17cfc7a30198ee155db95b0d5905a15bfb9b152e0bea192a398fb3ace099
materialize neutral e238553ce2f5e2a93f281925b4efc018b370660ce7fb2dd2e254162301298bef
