#!/usr/bin/env bash
set -euo pipefail

# Session module: move current session and stay in the session-switch key table.

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

direction="${1:-}"
if [[ "$direction" != "left" && "$direction" != "right" ]]; then
  exit 0
fi

python3 "$_modroot/helper.py" move "$direction"
tmux switch-client -T session-switch
