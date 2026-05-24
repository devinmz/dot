#!/usr/bin/env python3
"""Pane helpers for tmux/module/pane."""

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


def display_message(message: str) -> None:
    run_tmux(["display-message", message], check=False)


def current_pane_id() -> str:
    return run_tmux(["display-message", "-p", "#{pane_id}"], capture=True)


def current_window_id() -> str:
    return run_tmux(["display-message", "-p", "#{window_id}"], capture=True)


def list_panes() -> List[Dict[str, object]]:
    output = run_tmux(
        ["list-panes", "-t", current_window_id(), "-F", "#{pane_id} #{pane_left} #{pane_top} #{pane_width} #{pane_height}"],
        capture=True,
    )
    if not output:
        return []

    panes: List[Dict[str, object]] = []
    for line in output.splitlines():
        pane_id, left, top, width, height = line.split()
        left_i = int(left)
        top_i = int(top)
        width_i = int(width)
        height_i = int(height)
        panes.append(
            {
                "id": pane_id,
                "left": left_i,
                "top": top_i,
                "width": width_i,
                "height": height_i,
                "right": left_i + width_i,
                "bottom": top_i + height_i,
            }
        )
    return panes


def overlap(a0: int, a1: int, b0: int, b1: int) -> int:
    return max(0, min(a1, b1) - max(a0, b0))


def find_adjacent_pane(direction: str) -> Optional[str]:
    panes = list_panes()
    current_id = current_pane_id()
    current = next((pane for pane in panes if pane["id"] == current_id), None)
    if current is None:
        return None

    candidates: List[tuple[int, int, str]] = []
    for pane in panes:
        if pane["id"] == current_id:
            continue

        if direction == "left":
            dist = int(current["left"]) - int(pane["right"])
            ov = overlap(int(current["top"]), int(current["bottom"]), int(pane["top"]), int(pane["bottom"]))
        elif direction == "right":
            dist = int(pane["left"]) - int(current["right"])
            ov = overlap(int(current["top"]), int(current["bottom"]), int(pane["top"]), int(pane["bottom"]))
        elif direction == "up":
            dist = int(current["top"]) - int(pane["bottom"])
            ov = overlap(int(current["left"]), int(current["right"]), int(pane["left"]), int(pane["right"]))
        elif direction == "down":
            dist = int(pane["top"]) - int(current["bottom"])
            ov = overlap(int(current["left"]), int(current["right"]), int(pane["left"]), int(pane["right"]))
        else:
            return None

        if dist < 0 or ov <= 0:
            continue
        candidates.append((dist, -ov, str(pane["id"])))

    if not candidates:
        return None

    candidates.sort()
    return candidates[0][2]


def command_swap(direction: str) -> None:
    direction = direction.lower()
    if direction not in {"left", "right", "up", "down"}:
        return

    source_pane = current_pane_id()
    panes = list_panes()
    source_info = next((pane for pane in panes if pane["id"] == source_pane), None)
    target_pane = find_adjacent_pane(direction)
    if not source_pane or source_info is None or not target_pane:
        display_message(f"No pane on the {direction}.")
        return

    run_tmux(["swap-pane", "-d", "-s", source_pane, "-t", target_pane], check=False)
    # swap-pane only swaps content into the other layout cell; resize so the original
    # pane content carries its old width/height to the new side and the divider moves.
    if direction in {"left", "right"}:
        run_tmux(["resize-pane", "-t", source_pane, "-x", str(source_info["width"])], check=False)
    else:
        run_tmux(["resize-pane", "-t", source_pane, "-y", str(source_info["height"])], check=False)
    # Follow the original pane content after the swap so its new size/position is obvious.
    run_tmux(["select-pane", "-t", source_pane], check=False)
    run_tmux(["refresh-client", "-S"], check=False)


def main(argv: List[str]) -> None:
    if len(argv) < 2:
        return

    cmd = argv[1]
    if cmd == "swap" and len(argv) >= 3:
        command_swap(argv[2])


if __name__ == "__main__":
    main(sys.argv)
