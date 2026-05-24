#!/usr/bin/env python3
"""window API"""

import subprocess
import sys
from typing import Dict, List, Optional


def run_tmux(args: List[str], check: bool = True, capture: bool = False) -> str:
    kwargs: Dict[str, object] = {"check": check}
    if capture:
        kwargs["stdout"] = subprocess.PIPE
        kwargs["text"] = True
    result = subprocess.run(["tmux", *args], **kwargs)
    if capture:
        return result.stdout.rstrip("\n")
    return ""


def current_window_id() -> str:
    return run_tmux(["display-message", "-p", "#{window_id}"], capture=True)


def current_window_index() -> int:
    raw = run_tmux(["display-message", "-p", "#{window_index}"], capture=True)
    try:
        return int(raw)
    except ValueError:
        return 1


def display_message(message: str) -> None:
    run_tmux(["display-message", message], check=False)


def list_windows() -> List[Dict[str, object]]:
    output = run_tmux(
        ["list-windows", "-F", "#{window_id}\t#{window_index}\t#{window_name}"],
        capture=True,
    )
    if not output:
        return []

    windows: List[Dict[str, object]] = []
    for line in output.splitlines():
        window_id, index_str, name = line.split("\t", 2)
        try:
            index = int(index_str)
        except ValueError:
            continue
        windows.append({
            "id": window_id,
            "index": index,
            "name": name,
            "label": name,
        })

    windows.sort(key=lambda item: int(item["index"]))
    return windows


def sanitize_label(label: str) -> str:
    stripped = label.strip()
    return stripped or "window"


def find_window(target: str, windows: List[Dict[str, object]]) -> Optional[Dict[str, object]]:
    raw = target.strip()
    if not raw:
        current_id = current_window_id()
        return next((window for window in windows if window["id"] == current_id), None)

    if raw.isdigit():
        wanted_index = int(raw)
        for window in windows:
            if int(window["index"]) == wanted_index:
                return window

    for field in ("id", "name", "label"):
        for window in windows:
            value = window.get(field)
            if isinstance(value, str) and value == raw:
                return window
    return None


def command_switch(index_str: str) -> None:
    try:
        index = int(index_str)
    except ValueError:
        return
    if index < 1:
        return
    run_tmux(["select-window", "-t", f":{index}"], check=False)
    run_tmux(["refresh-client", "-S"], check=False)


def command_create(mode: str, label: str, current_path: str) -> None:
    before_windows = list_windows()
    anchor_index = current_window_index()
    target_index = len(before_windows) + 1
    if mode == "after-current":
        target_index = anchor_index + 1

    tmux_args = ["new-window", "-d", "-P", "-F", "#{window_id}"]
    if current_path:
        tmux_args.extend(["-c", current_path])
    normalized = label.strip()
    if normalized:
        tmux_args.extend(["-n", normalized])

    new_window_id = run_tmux(tmux_args, capture=True)
    if not new_window_id:
        return

    run_tmux(["move-window", "-d", "-s", new_window_id, "-t", f":{target_index}"], check=False)
    run_tmux(["select-window", "-t", new_window_id], check=False)
    run_tmux(["refresh-client", "-S"], check=False)


def command_rename(label: str) -> None:
    normalized = sanitize_label(label)
    run_tmux(["rename-window", "--", normalized], check=False)
    run_tmux(["refresh-client", "-S"], check=False)


def command_move(direction: str) -> None:
    direction = direction.lower()
    windows = list_windows()
    current_id = current_window_id()
    indices = {str(window["id"]): idx for idx, window in enumerate(windows)}
    if current_id not in indices:
        return

    pos = indices[current_id]
    if direction == "left" and pos > 0:
        target_id = str(windows[pos - 1]["id"])
    elif direction == "right" and pos < len(windows) - 1:
        target_id = str(windows[pos + 1]["id"])
    else:
        return

    run_tmux(["swap-window", "-d", "-s", current_id, "-t", target_id], check=False)
    run_tmux(["select-window", "-t", current_id], check=False)
    run_tmux(["refresh-client", "-S"], check=False)


def command_kill(target: str = "") -> None:
    windows = list_windows()
    if not windows:
        return

    target_window = find_window(target, windows)
    if target_window is None:
        wanted = target.strip() or "(current)"
        display_message(f"Window not found: {wanted}")
        return

    target_id = str(target_window["id"])
    current_id = current_window_id()
    if len(windows) == 1:
        run_tmux(["kill-window", "-t", target_id], check=False)
        return

    if target_id == current_id:
        ids = [str(window["id"]) for window in windows]
        pos = ids.index(current_id)
        adjacent_id = ids[pos + 1] if pos == 0 else ids[pos - 1]
        run_tmux(["select-window", "-t", adjacent_id], check=False)

    run_tmux(["kill-window", "-t", target_id], check=False)
    run_tmux(["refresh-client", "-S"], check=False)


def main(argv: List[str]) -> None:
    if len(argv) < 2:
        return

    cmd = argv[1]
    if cmd == "switch" and len(argv) >= 3:
        command_switch(argv[2])
    elif cmd == "create":
        mode = argv[2] if len(argv) >= 3 else "append-last"
        label = argv[3] if len(argv) >= 4 else ""
        current_path = argv[4] if len(argv) >= 5 else ""
        command_create(mode, label, current_path)
    elif cmd == "rename" and len(argv) >= 3:
        command_rename(argv[2])
    elif cmd == "move" and len(argv) >= 3:
        command_move(argv[2])
    elif cmd == "kill":
        command_kill(argv[2] if len(argv) >= 3 else "")


if __name__ == "__main__":
    main(sys.argv)
