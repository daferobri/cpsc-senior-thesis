#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Remove this experiment's generated artifacts; keep shared DUB caches intact.
rm -rf -- build .dub
