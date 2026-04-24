#!/usr/bin/env python3

from pathlib import Path
import sys

TMUX_ROOT = Path(__file__).resolve().parents[2]
if str(TMUX_ROOT) not in sys.path:
    sys.path.insert(0, str(TMUX_ROOT))

from module.core.bind_api import register_self


def register(registry):
    registry.bind(
        "c",
        'command-prompt -p "Window name:" "run-shell \\"~/.config/tmux/module/window/create.sh after-current \'%%\' #{q:pane_current_path}\\""',
        description="Prompt for a window name and create it right after the current window.",
    )
    registry.bind(
        "s",
        'command-prompt -p "Window name:" "run-shell \\"~/.config/tmux/module/window/create.sh append-last \'%%\' #{q:pane_current_path}\\""',
        description="Prompt for a window name and create it at the end of the window list.",
    )
    registry.bind(
        "r",
        'command-prompt -I "#{window_name}" -p "Window name:" "run-shell \\"python3 ~/.config/tmux/module/window/helper.py rename \'%%\'\\""',
        description="Prompt for a new name and rename the current tmux window.",
    )
    registry.bind(
        "k",
        'command-prompt -p "Kill window :" "run-shell \\"~/.config/tmux/module/window/kill.sh \'%%\'\\""',
        description="Prompt for a window to kill by index or name; blank kills the current window.",
    )
    for idx in range(1, 10):
        registry.bind(
            str(idx),
            f"select-window -t :{idx}",
            description=f"Switch to window {idx}.",
        )
    registry.bind(
        "C-n",
        "switch-client -T window-switch",
        table="root",
        description="Enter the window-switch key table; press digits to jump or arrows to reorder windows.",
    )
    for idx in range(1, 10):
        registry.bind(
            str(idx),
            f'run-shell -b "~/.config/tmux/module/window/switch_index.sh {idx}"',
            table="window-switch",
            description=f"Switch to window {idx} after pressing Ctrl+w.",
        )
    registry.bind(
        "Left",
        'run-shell -b "~/.config/tmux/module/window/switch_move.sh left"',
        table="window-switch",
        description="Move the current window one position to the left and stay in the window-switch key table.",
    )
    registry.bind(
        "Right",
        'run-shell -b "~/.config/tmux/module/window/switch_move.sh right"',
        table="window-switch",
        description="Move the current window one position to the right and stay in the window-switch key table.",
    )


if __name__ == "__main__":
    raise SystemExit(register_self(__file__))
