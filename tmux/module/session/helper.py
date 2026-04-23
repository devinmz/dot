#!/usr/bin/env python3
"""Session ordering helpers for tmux/module/session only (not tmux/scripts)."""

import re
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


def current_window_id() -> str:
    return run_tmux(["display-message", "-p", "#{window_id}"], capture=True)


def display_message(message: str) -> None:
    run_tmux(["display-message", message], check=False)


def find_session(target: str, sessions: List[Dict[str, object]]) -> Optional[Dict[str, object]]:
    raw = target.strip()
    if not raw:
        current_id = current_session_id()
        return next((session for session in sessions if session["id"] == current_id), None)

    if raw.isdigit():
        index = int(raw)
        if 1 <= index <= len(sessions):
            return sessions[index - 1]

    for field in ("id", "name", "label"):
        for session in sessions:
            value = session.get(field)
            if isinstance(value, str) and value == raw:
                return session
    return None


def command_switch(index_str: str) -> None:
    try:
        index = int(index_str)
    except ValueError:
        return
    if index < 1:
        return
    sessions = list_sessions()
    if index > len(sessions):
        return
    run_tmux(["switch-client", "-t", sessions[index - 1]["id"]], check=False)
    run_tmux(["refresh-client", "-S"], check=False)


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


def command_move(direction: str) -> None:
    direction = direction.lower()
    sessions = list_sessions()
    current_id = current_session_id()
    indices = {session["id"]: idx for idx, session in enumerate(sessions)}
    if current_id not in indices:
        return
    pos = indices[current_id]
    if direction == "left" and pos > 0:
        sessions[pos - 1], sessions[pos] = sessions[pos], sessions[pos - 1]
    elif direction == "right" and pos < len(sessions) - 1:
        sessions[pos], sessions[pos + 1] = sessions[pos + 1], sessions[pos]
    else:
        return
    apply_order(sessions)


def command_created() -> None:
    command_ensure()


def command_kill(target: str = "") -> None:
    sessions = list_sessions()
    if not sessions:
        return

    target_session = find_session(target, sessions)
    if target_session is None:
        wanted = target.strip() or "(current)"
        display_message(f"Session not found: {wanted}")
        return

    target_id = str(target_session["id"])
    current_id = current_session_id()
    remaining_sessions = [session for session in sessions if session["id"] != target_id]

    if not remaining_sessions:
        run_tmux(["kill-session", "-t", target_id], check=False)
        return

    ids = [str(s["id"]) for s in sessions]
    if current_id not in ids:
        apply_order(remaining_sessions)
        run_tmux(["kill-session", "-t", target_id], check=False)
        return

    if target_id == current_id:
        k = ids.index(current_id)
        # 第一个 session -> 切到下一个；否则 -> 切到前一个
        adjacent_k = k + 1 if k == 0 else k - 1
        adjacent_id = ids[adjacent_k]
        apply_order(remaining_sessions)
        run_tmux(["switch-client", "-t", adjacent_id], check=False)
        run_tmux(["kill-session", "-t", target_id], check=False)
    else:
        apply_order(remaining_sessions)
        run_tmux(["kill-session", "-t", target_id], check=False)

    run_tmux(["refresh-client", "-S"], check=False)


def command_move_window_to_session(index_str: str) -> None:
    try:
        index = int(index_str)
    except ValueError:
        return
    if index < 1:
        return
    sessions = list_sessions()
    if index > len(sessions):
        return
    target_session_id = sessions[index - 1]["id"]
    source_window_id = current_window_id()
    if not source_window_id:
        return
    current_id = current_session_id()
    if target_session_id != current_id:
        run_tmux(["move-window", "-s", source_window_id, "-t", f"{target_session_id}:"], check=False)
    run_tmux(["switch-client", "-t", target_session_id], check=False)


def main(argv: List[str]) -> None:
    if len(argv) < 2:
        return
    cmd = argv[1]
    if cmd == "switch" and len(argv) >= 3:
        command_switch(argv[2])
    elif cmd == "insert-right" and len(argv) >= 4:
        command_insert_right(argv[2], argv[3])
    elif cmd == "move" and len(argv) >= 3:
        command_move(argv[2])
    elif cmd == "ensure":
        command_ensure()
    elif cmd == "created":
        command_created()
    elif cmd == "rename" and len(argv) >= 3:
        command_rename(argv[2])
    elif cmd == "kill-current":
        command_kill()
    elif cmd == "kill":
        command_kill(argv[2] if len(argv) >= 3 else "")
    elif cmd == "move-window-to" and len(argv) >= 3:
        command_move_window_to_session(argv[2])


if __name__ == "__main__":
    main(sys.argv)
