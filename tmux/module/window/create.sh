#!/usr/bin/env bash
set -euo pipefail

# Window module: create a window after current or at end.

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mode="${1:-append-last}"
label="${2:-}"
current_path="${3:-}"

exec python3 "$_modroot/helper.py" create "$mode" "$label" "$current_path"
