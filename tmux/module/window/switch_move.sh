#!/usr/bin/env bash
set -euo pipefail

# Window module: move current window and stay in the window-switch key table.

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

direction="${1:-}"
if [[ "$direction" != "left" && "$direction" != "right" ]]; then
  exit 0
fi

python3 "$_modroot/helper.py" move "$direction"
tmux switch-client -T window-switch
