#!/usr/bin/env python3

from pathlib import Path
import sys

TMUX_ROOT = Path(__file__).resolve().parents[2]
if str(TMUX_ROOT) not in sys.path:
    sys.path.insert(0, str(TMUX_ROOT))

from module.core.bind_api import register_self


def register(registry):
    registry.bind(
        "G",
        'command-prompt -p "Session name:" "run-shell \\"~/.config/tmux/module/session/create_session.sh \'%%\' #{q:session_id} #{q:pane_current_path}\\""',
        description="Prompt for a session name and create a session in the current pane path.",
    )
    registry.bind(
        "X",
        'confirm-before -p "Kill session #S & switch to previous? (y/n)" "run-shell \\"~/.config/tmux/module/session/kill_session.sh\\""',
        description="Kill the current session after switching to the previous ordered session.",
    )
    registry.bind(
        "k",
        'confirm-before -p "kill session #S? (y/n)" kill-session',
        description="Kill the current tmux session with confirmation.",
    )
    registry.bind(
        "d",
        "detach-client",
        description="Detach the current tmux client.",
    )
    registry.bind(
        "M-s",
        'run-shell "~/.config/tmux/module/session/switch_session_menu.sh"',
        table="root",
        description="Open the interactive session chooser.",
    )
    for idx in range(1, 10):
        registry.bind(
            f"C-{idx}",
            f'run-shell -b "~/.config/tmux/module/session/switch_session_by_index.sh {idx}"',
            table="root",
            description=f"Switch to the session whose name starts with {idx}-.",
        )


if __name__ == "__main__":
    raise SystemExit(register_self(__file__))
