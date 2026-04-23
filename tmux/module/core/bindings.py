#!/usr/bin/env python3

from pathlib import Path
import sys

TMUX_ROOT = Path(__file__).resolve().parents[2]
if str(TMUX_ROOT) not in sys.path:
    sys.path.insert(0, str(TMUX_ROOT))

from module.core.bind_api import register_self


def register(registry):
    registry.bind(
        "L",
        'run-shell "python3 ~/.config/tmux/module/core/bind_registry.py reload"',
        description="Reload tmux config via registry-driven unbind and regenerate flow.",
    )


if __name__ == "__main__":
    raise SystemExit(register_self(__file__))
