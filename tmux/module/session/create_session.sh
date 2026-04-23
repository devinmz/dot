#!/usr/bin/env bash
set -euo pipefail

# Args: [session_label] [current_session_id] [pane_current_path]
# Session module only — uses session_helper.py (not tmux/scripts).

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

label="${1:-}"
current_session_id="${2:-}"
current_path="${3:-}"

LOCK="/tmp/tmux-module-new-session.lock"
touch "$LOCK"

uniq="ns-$$-${RANDOM}"
tmux_args=(new-session -d -P -s "$uniq" -F '#{session_id}')
if [ -n "$current_path" ]; then
  tmux_args+=( -c "$current_path" )
  printf -v start_cmd 'cd %q && exec ${SHELL:-/bin/zsh} -l' "$current_path"
  tmux_args+=( "$start_cmd" )
fi

session_id=$(tmux "${tmux_args[@]}" 2>/dev/null || true)

if [ -z "$session_id" ]; then
  rm -f "$LOCK"
  exit 0
fi

if [ -n "$current_session_id" ]; then
  python3 "$_modroot/session_helper.py" insert-right "$current_session_id" "$session_id"
else
  python3 "$_modroot/session_helper.py" ensure
fi

rm -f "$LOCK"

tmux switch-client -t "$session_id"

normalized=$(printf '%s' "$label" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [[ -n "$normalized" ]]; then
  python3 "$_modroot/session_helper.py" rename "$normalized"
fi
