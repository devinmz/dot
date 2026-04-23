#!/usr/bin/env python3
"""Maintain a registry-driven tmux bind mapping and apply bindings directly."""

from __future__ import annotations

import argparse
import importlib.util
import json
import shlex
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


TMUX_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CONFIG = TMUX_ROOT / "tmux.conf"
DEFAULT_MAPPING = TMUX_ROOT / "tmp" / "bind-mapping.json"
MODULE_ROOT = TMUX_ROOT / "module"

if str(TMUX_ROOT) not in sys.path:
    sys.path.insert(0, str(TMUX_ROOT))

from module.core.bind_api import BindingRegistry, BindingSpec  # noqa: E402


def empty_payload() -> dict:
    return {
        "version": 3,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "config_root": str(TMUX_ROOT),
        "bindings": [],
    }


def read_payload(path: Path) -> dict:
    if not path.exists():
        return empty_payload()
    try:
        payload = json.loads(path.read_text())
    except json.JSONDecodeError:
        return empty_payload()
    if not isinstance(payload, dict):
        return empty_payload()
    payload.setdefault("version", 3)
    payload.setdefault("config_root", str(TMUX_ROOT))
    payload.setdefault("bindings", [])
    return payload


def load_bindings_from_file(bindings_file: Path) -> list[BindingSpec]:
    path = bindings_file.resolve()
    if not path.exists():
        return []

    module_key = path.relative_to(MODULE_ROOT).as_posix().replace("/", ".").removesuffix(".py")
    spec = importlib.util.spec_from_file_location(f"tmux_bindings_{module_key.replace('.', '_')}", path)
    if spec is None or spec.loader is None:
        return []

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    registry = BindingRegistry(module_key)
    register = getattr(module, "register", None)
    if callable(register):
        register(registry)

    bindings: list[BindingSpec] = []
    seen: set[tuple[str, str]] = set()
    for binding in registry.bindings:
        key = (binding.table, binding.key)
        if key in seen:
            continue
        seen.add(key)
        bindings.append(binding)
    return bindings


def write_payload(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n")


def serialize_binding(binding: BindingSpec) -> dict:
    return {
        "module": binding.module,
        "key": binding.key,
        "table": binding.table,
        "repeatable": binding.repeatable,
        "description": binding.description,
        "command": binding.command,
        "rendered": binding.render(),
        "unbind_command": binding.unbind_command(),
    }


def load_mapping(path: Path) -> list[list[str]]:
    if not path.exists():
        return []
    payload = json.loads(path.read_text())
    commands: list[list[str]] = []
    for item in payload.get("bindings", []):
        command = item.get("unbind_command")
        if isinstance(command, list) and all(isinstance(part, str) for part in command):
            commands.append(command)
    return commands


def run_tmux(args: list[str]) -> None:
    subprocess.run(
        ["tmux", *args],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def apply_bindings(bindings: list[BindingSpec]) -> None:
    for binding in bindings:
        subprocess.run(
            ["tmux", *shlex.split(binding.render())],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def cmd_reset(mapping_path: Path) -> int:
    write_payload(mapping_path, empty_payload())
    return 0


def cmd_register(mapping_path: Path, bindings_file: Path) -> int:
    payload = read_payload(mapping_path)
    items = payload.get("bindings", [])
    if not isinstance(items, list):
        items = []

    by_key: dict[tuple[str, str], dict] = {}
    for item in items:
        if not isinstance(item, dict):
            continue
        table = item.get("table")
        key = item.get("key")
        if isinstance(table, str) and isinstance(key, str):
            by_key[(table, key)] = item

    for binding in load_bindings_from_file(bindings_file):
        by_key[(binding.table, binding.key)] = serialize_binding(binding)

    payload["version"] = 3
    payload["generated_at"] = datetime.now(timezone.utc).isoformat()
    payload["bindings"] = list(by_key.values())
    write_payload(mapping_path, payload)
    return 0


def cmd_apply(mapping_path: Path) -> int:
    payload = read_payload(mapping_path)
    items = payload.get("bindings", [])
    commands: list[str] = []
    for item in items:
        if not isinstance(item, dict):
            continue
        rendered = item.get("rendered")
        if isinstance(rendered, str) and rendered:
            commands.append(rendered)
    for rendered in commands:
        subprocess.run(
            ["tmux", *shlex.split(rendered)],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    return 0


def cmd_unbind(mapping_path: Path) -> int:
    for command in load_mapping(mapping_path):
        run_tmux(command)
    return 0


def cmd_reload(mapping_path: Path, config_path: Path) -> int:
    cmd_unbind(mapping_path)
    run_tmux(["source-file", str(config_path)])
    run_tmux(["display-message", "Config reloaded!"])
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--mapping",
        default=str(DEFAULT_MAPPING),
        help="Path to bind mapping JSON file.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("reset", help="Reset the JSON registry before module registration.")
    register_parser = subparsers.add_parser("register", help="Register one module's bindings.py into the JSON registry.")
    register_parser.add_argument("bindings_file", help="Path to a module bindings.py file.")
    subparsers.add_parser("apply", help="Apply bindings listed in the JSON registry directly.")
    subparsers.add_parser("unbind", help="Unbind all keys listed in the JSON registry.")

    reload_parser = subparsers.add_parser(
        "reload",
        help="Unbind previous keys and source the main tmux config.",
    )
    reload_parser.add_argument(
        "--config",
        default=str(DEFAULT_CONFIG),
        help="Main tmux config file to source.",
    )
    return parser


def main(argv: list[str]) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    mapping_path = Path(args.mapping).expanduser()

    if args.command == "reset":
        return cmd_reset(mapping_path)
    if args.command == "register":
        bindings_file = Path(args.bindings_file).expanduser()
        return cmd_register(mapping_path, bindings_file)
    if args.command == "apply":
        return cmd_apply(mapping_path)
    if args.command == "unbind":
        return cmd_unbind(mapping_path)
    if args.command == "reload":
        config_path = Path(args.config).expanduser()
        return cmd_reload(mapping_path, config_path)

    parser.error(f"unknown command: {args.command}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
