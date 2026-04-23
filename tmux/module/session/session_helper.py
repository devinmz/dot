#!/usr/bin/env python3
"""Session ordering helpers for tmux/module/session only (not tmux/scripts)."""

import re
import subprocess
import sys
from typing import Dict, List


def run_tmux(args: List[str], check: bool = True, capture: bool = False) -> str:
    kwargs: Dict[str, object] = {"check": check}
    if capture:
        kwargs["stdout"] = subprocess.PIPE
        kwargs["text"] = True
    result = subprocess.run(["tmux", *args], **kwargs)
    if capture:
        return result.stdout.rstrip("\n")
    return ""


def list_sessions() -> List[Dict[str, object]]:
    output = run_tmux(
        ["list-sessions", "-F", "#{session_id}\t#{session_name}\t#{session_created}"],
        capture=True,
    )
    if not output:
        return []

    sessions: List[Dict[str, object]] = []
    for line in output.splitlines():
        session_id, name, created_str = line.split("\t")
        created = int(created_str)
        match = re.match(r"^(\d+)-(.*)$", name)
        if match:
            index = int(match.group(1))
            label = match.group(2)
        else:
            index = None
            label = name
        sessions.append({
            "id": session_id,
            "name": name,
            "created": created,
            "index": index,
            "label": label,
        })

    def sort_key(entry: Dict[str, object]):
        idx = entry["index"]
        return (0, idx) if idx is not None else (1, entry["created"])

    sessions.sort(key=sort_key)
    return sessions


def sanitize_label(label: str) -> str:
    stripped = label.strip()
    return stripped or "session"


def apply_order(ordered_sessions: List[Dict[str, object]]) -> None:
    for position, session in enumerate(ordered_sessions, start=1):
        label = sanitize_label(str(session["label"]))
        new_name = f"{position}-{label}"
        run_tmux(["rename-session", "-t", session["id"], new_name])


def current_session_id() -> str:
    return run_tmux(["display-message", "-p", "#{session_id}"], capture=True)


def command_ensure() -> None:
    sessions = list_sessions()
    if sessions:
        apply_order(sessions)


def command_rename(label: str) -> None:
    label = sanitize_label(label)
    current_id = current_session_id()
    sessions = list_sessions()
    for session in sessions:
        if session["id"] == current_id:
            session["label"] = label
            break
    else:
        return
    apply_order(sessions)


def command_insert_right(anchor_id: str, moving_id: str) -> None:
    if not anchor_id or not moving_id or anchor_id == moving_id:
        command_ensure()
        return

    sessions = list_sessions()
    indices = {session["id"]: idx for idx, session in enumerate(sessions)}
    if anchor_id not in indices or moving_id not in indices:
        command_ensure()
        return

    moving_session = sessions.pop(indices[moving_id])
    anchor_pos = next((idx for idx, session in enumerate(sessions) if session["id"] == anchor_id), None)
    if anchor_pos is None:
        sessions.append(moving_session)
    else:
        sessions.insert(anchor_pos + 1, moving_session)
    apply_order(sessions)


def command_kill_current() -> None:
    sessions = list_sessions()
    if not sessions:
        return
    current_id = current_session_id()
    ids = [str(s["id"]) for s in sessions]
    if current_id not in ids:
        run_tmux(["kill-session"], check=False)
        return
    k = ids.index(current_id)
    if len(sessions) == 1:
        run_tmux(["kill-session", "-t", current_id], check=False)
        return
    prev_k = k - 1 if k > 0 else len(sessions) - 1
    target_id = ids[prev_k]
    run_tmux(["switch-client", "-t", target_id], check=False)
    run_tmux(["kill-session", "-t", current_id], check=False)
    run_tmux(["refresh-client", "-S"], check=False)


def main(argv: List[str]) -> None:
    if len(argv) < 2:
        return
    cmd = argv[1]
    if cmd == "insert-right" and len(argv) >= 4:
        command_insert_right(argv[2], argv[3])
    elif cmd == "ensure":
        command_ensure()
    elif cmd == "rename" and len(argv) >= 3:
        command_rename(argv[2])
    elif cmd == "kill-current":
        command_kill_current()


if __name__ == "__main__":
    main(sys.argv)
