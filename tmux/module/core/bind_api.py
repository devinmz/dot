#!/usr/bin/env python3
"""Binding registry primitives for tmux config loading."""

from __future__ import annotations

from dataclasses import dataclass, replace
from pathlib import Path
import subprocess


@dataclass(frozen=True)
class BindingSpec:
    key: str
    command: str
    table: str = "prefix"
    repeatable: bool = False
    description: str = ""
    module: str = ""

    def with_module(self, module: str) -> "BindingSpec":
        return replace(self, module=module)

    def render(self) -> str:
        parts = ["bind"]
        if self.repeatable:
            parts.append("-r")
        if self.table == "root":
            parts.append("-n")
        elif self.table != "prefix":
            parts.extend(["-T", self.table])
        parts.append(self.key)
        parts.append(self.command)
        return " ".join(parts)

    def unbind_command(self) -> list[str]:
        if self.table == "root":
            return ["unbind", "-n", self.key]
        if self.table == "prefix":
            return ["unbind", self.key]
        return ["unbind", "-T", self.table, self.key]


def bind(
    key: str,
    command: str,
    *,
    table: str = "prefix",
    repeatable: bool = False,
    description: str = "",
) -> BindingSpec:
    return BindingSpec(
        key=key,
        command=command,
        table=table,
        repeatable=repeatable,
        description=description,
    )


class BindingRegistry:
    """Per-module binding collector used by module bindings.py files."""

    def __init__(self, module: str):
        self.module = module
        self._bindings: list[BindingSpec] = []

    @property
    def bindings(self) -> list[BindingSpec]:
        return list(self._bindings)

    def add(self, binding: BindingSpec) -> BindingSpec:
        binding = binding.with_module(self.module)
        self._bindings.append(binding)
        return binding

    def bind(
        self,
        key: str,
        command: str,
        *,
        table: str = "prefix",
        repeatable: bool = False,
        description: str = "",
    ) -> BindingSpec:
        return self.add(
            bind(
                key,
                command,
                table=table,
                repeatable=repeatable,
                description=description,
            )
        )


def register_self(bindings_file: str) -> int:
    """Register the current bindings.py file through bind_registry.py."""
    core_dir = Path(__file__).resolve().parent
    registry_script = core_dir / "bind_registry.py"
    result = subprocess.run(
        ["python3", str(registry_script), "register", str(Path(bindings_file).resolve())],
        check=False,
    )
    return int(result.returncode)
