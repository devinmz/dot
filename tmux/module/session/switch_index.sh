#!/usr/bin/env bash
set -euo pipefail

# Session module: switch by sorted session index via helper.py.

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

index="$1"

if [[ -z "$index" || ! "$index" =~ ^[0-9]+$ ]]; then
  exit 0
fi

exec python3 "$_modroot/helper.py" switch "$index"
