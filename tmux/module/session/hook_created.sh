#!/usr/bin/env bash
set -euo pipefail

LOCK="/tmp/tmux-module-new-session.lock"
if [[ -f "$LOCK" ]]; then
  exit 0
fi

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$_modroot/helper.py" created
