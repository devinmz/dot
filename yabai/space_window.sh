#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <focus|send> <space-index>" >&2
  exit 1
fi

mode="$1"
target_index="$2"

if [[ ! "$target_index" =~ ^[0-9]+$ ]]; then
  echo "space index must be a positive integer" >&2
  exit 1
fi

space_exists() {
  local idx="$1"
  yabai -m query --spaces | python3 - "$idx" <<'PY'
import json
import sys

target = int(sys.argv[1])
spaces = json.load(sys.stdin)
print("yes" if any(space.get("index") == target for space in spaces) else "no")
PY
}

focused_display_index() {
  yabai -m query --displays | python3 - <<'PY'
import json
import sys

displays = json.load(sys.stdin)
focused = next((display for display in displays if display.get("has-focus")), None)
if focused is None:
    sys.exit(1)
print(focused["index"])
PY
}

display_index="$(focused_display_index)"

while [[ "$(space_exists "$target_index")" != "yes" ]]; do
  yabai -m display --focus "$display_index"
  yabai -m space --create
  sleep 0.1
done

yabai -m window --space "$target_index"

if [[ "$mode" == "focus" ]]; then
  yabai -m space --focus "$target_index"
elif [[ "$mode" != "send" ]]; then
  echo "unknown mode: $mode" >&2
  exit 1
fi
