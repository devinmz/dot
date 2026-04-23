#!/usr/bin/env python3

from pathlib import Path
import sys

TMUX_ROOT = Path(__file__).resolve().parents[2]
if str(TMUX_ROOT) not in sys.path:
    sys.path.insert(0, str(TMUX_ROOT))

from module.core.bind_api import register_self


def register(registry):
    registry.bind(
        "C",
        'command-prompt -p "Session name:" "run-shell \\"~/.config/tmux/module/session/create.sh after-current \'%%\' #{q:session_id} #{q:pane_current_path}\\""',
        description="Prompt for a session name and create a session right after the current session.",
    )
    registry.bind(
        "S",
        'command-prompt -p "Session name:" "run-shell \\"~/.config/tmux/module/session/create.sh append-last \'%%\' #{q:session_id} #{q:pane_current_path}\\""',
        description="Prompt for a session name and create a session at the end of the session list.",
    )
    registry.bind(
        "R",
        'command-prompt -I "#{session_name}" -p "Session name:" "rename-session -- \'%%\'"',
        description="Prompt for a new name and rename the current tmux session.",
    )
    registry.bind(
        "K",
        'confirm-before -p "Kill session #S & switch to adjacent? (y/n)" "run-shell \\"~/.config/tmux/module/session/kill.sh\\""',
        description="Kill the current session; switch to next if first, otherwise previous (kill directly if only one).",
    )
    # registry.bind(
    #     "K",
    #     'confirm-before -p "kill session #S? (y/n)" kill-session',
    #     description="Kill the current tmux session with confirmation.",
    # )
    registry.bind(
        "D",
        "detach-client",
        description="Detach the current tmux client.",
    )
    registry.bind(
        "Left",
        'run-shell -b "python3 ~/.config/tmux/module/session/helper.py move left"',
        description="Move the current session one position to the left in the ordered session list.",
    )
    registry.bind(
        "Right",
        'run-shell -b "python3 ~/.config/tmux/module/session/helper.py move right"',
        description="Move the current session one position to the right in the ordered session list.",
    )
    registry.bind(
        "C-l",
        "switch-client -T session-switch",
        table="root",
        description="Enter the session-switch key table; press digits to jump or arrows to reorder sessions.",
    )
    for idx in range(1, 9):
        registry.bind(
            str(idx),
            f'run-shell -b "~/.config/tmux/module/session/switch_index.sh {idx}"',
            table="session-switch",
            description=f"Switch to the session at sorted index {idx} after pressing Ctrl+l.",
        )
    registry.bind(
        "Left",
        'run-shell -b "~/.config/tmux/module/session/switch_move.sh left"',
        table="session-switch",
        description="Move the current session one position to the left and stay in the session-switch key table.",
    )
    registry.bind(
        "Right",
        'run-shell -b "~/.config/tmux/module/session/switch_move.sh right"',
        table="session-switch",
        description="Move the current session one position to the right and stay in the session-switch key table.",
    )


if __name__ == "__main__":
    raise SystemExit(register_self(__file__))


