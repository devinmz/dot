#!/usr/bin/env bash
set -euo pipefail

# Pane module: swap the current pane with the adjacent pane in a direction.

direction="${1:-}"

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec python3 "$_modroot/helper.py" swap "$direction"
