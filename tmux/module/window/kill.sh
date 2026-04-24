#!/usr/bin/env bash
set -euo pipefail

# Window module: kill a target window; blank means current.

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec python3 "$_modroot/helper.py" kill "${1:-}"
