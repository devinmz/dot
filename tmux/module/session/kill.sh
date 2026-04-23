#!/usr/bin/env bash
set -euo pipefail

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$_modroot/helper.py" kill-current
