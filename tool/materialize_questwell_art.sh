#!/usr/bin/env bash
set -euo pipefail

# Compatibility entrypoint for existing automation. Committed fitted WebPs
# are the source of truth; never overwrite them with legacy base64 art.
cd "$(dirname "$0")/.."
python3 tool/verify_avatar_assets.py
