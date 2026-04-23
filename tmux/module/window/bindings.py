#!/usr/bin/env python3

from pathlib import Path
import sys

TMUX_ROOT = Path(__file__).resolve().parents[2]
if str(TMUX_ROOT) not in sys.path:
    sys.path.insert(0, str(TMUX_ROOT))

from module.core.bind_api import register_self


def register(registry):
    # registry.bind(
    #     "C",
    #     'command-prompt -p "窗口名:" "new-window -c \'#{pane_current_path}\' -n \'%%\'"',
    #     description="Prompt for a window name and create it in the current pane path.",
    # )
    for idx in range(1, 10):
        registry.bind(
            str(idx),
            f"select-window -t :{idx}",
            description=f"Switch to window {idx}.",
        )


if __name__ == "__main__":
    raise SystemExit(register_self(__file__))
