#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Combine dependencies so every D module uses the same Wasm/BetterC flags.
dub build --compiler=ldc2 --arch=wasm32-unknown-emscripten --combined "$@"

# DUB skips post-build hooks when its archive is up to date. Always link so
# missing web output and asset-only changes are picked up.
bash scripts/link.sh
