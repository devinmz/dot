#!/usr/bin/env bash
set -euo pipefail

# Args: [mode] [session_label] [current_session_id] [pane_current_path]
# Session module only — uses helper.py (not tmux/scripts).

_modroot="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mode="${1:-append-last}"
label="${2:-}"
current_session_id="${3:-}"
current_path="${4:-}"

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

case "$mode" in
  after-current)
    if [[ -n "$current_session_id" ]]; then
      python3 "$_modroot/helper.py" insert-right "$current_session_id" "$session_id"
    else
      python3 "$_modroot/helper.py" ensure
    fi
    ;;
  append-last|*)
    python3 "$_modroot/helper.py" ensure
    ;;
esac

rm -f "$LOCK"

tmux switch-client -t "$session_id"

normalized=$(printf '%s' "$label" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [[ -n "$normalized" ]]; then
  python3 "$_modroot/helper.py" rename "$normalized"
fi
