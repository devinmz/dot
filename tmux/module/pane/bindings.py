#!/usr/bin/env python3

from pathlib import Path
import sys

TMUX_ROOT = Path(__file__).resolve().parents[2]
if str(TMUX_ROOT) not in sys.path:
    sys.path.insert(0, str(TMUX_ROOT))

from module.core.bind_api import register_self


def register(registry):
    registry.bind("-", 'split-window -v -c "#{pane_current_path}"', description="Split the current pane vertically.")
    registry.bind("=", 'split-window -h -c "#{pane_current_path}"', description="Split the current pane horizontally.")
    registry.bind("h", "select-pane -L", description="Focus the pane to the left.")
    registry.bind("n", "select-pane -D", description="Focus the pane below.")
    registry.bind("e", "select-pane -U", description="Focus the pane above.")
    registry.bind("i", "select-pane -R", description="Focus the pane to the right.")
    registry.bind(
        "WheelUpPane",
        "send-keys -X -N 1 scroll-up",
        table="copy-mode-vi",
        description="Scroll up one line in copy-mode-vi.",
    )
    registry.bind(
        "WheelDownPane",
        "send-keys -X -N 1 scroll-down",
        table="copy-mode-vi",
        description="Scroll down one line in copy-mode-vi.",
    )
    registry.bind(
        "WheelUpPane",
        "send-keys -X -N 1 scroll-up",
        table="copy-mode",
        description="Scroll up one line in copy-mode.",
    )
    registry.bind(
        "WheelDownPane",
        "send-keys -X -N 1 scroll-down",
        table="copy-mode",
        description="Scroll down one line in copy-mode.",
    )
    registry.bind(
        "WheelUpPane",
        'if-shell -F -t = "#{?pane_in_mode,1,#{alternate_on}}" "send-keys -M" "copy-mode -e; send-keys -X -N 1 scroll-up"',
        table="root",
        description="Pass wheel-up through or enter copy mode and scroll up.",
    )
    registry.bind(
        "WheelDownPane",
        'if-shell -F -t = "#{?pane_in_mode,1,#{alternate_on}}" "send-keys -M" "send-keys -X -N 1 scroll-down"',
        table="root",
        description="Pass wheel-down through or scroll copy mode down.",
    )
    registry.bind("Down", "resize-pane -D 1", repeatable=True, description="Resize the pane down by one cell.")
    registry.bind("Up", "resize-pane -U 1", repeatable=True, description="Resize the pane up by one cell.")


if __name__ == "__main__":
    raise SystemExit(register_self(__file__))
