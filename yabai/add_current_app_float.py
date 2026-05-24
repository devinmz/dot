#!/usr/bin/env python3

import json
import pathlib
import re
import subprocess
import sys


START_MARKER = "# Always-float app rules"
END_MARKER = "# End always-float app rules"


def run(cmd: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, check=True, text=True, capture_output=True)


def main() -> int:
    window = json.loads(run(["yabai", "-m", "query", "--windows", "--window"]).stdout)
    app_name = window.get("app", "").strip()

    if not app_name:
      print("无法识别当前窗口的 app 名称。", file=sys.stderr)
      return 1

    escaped_name = re.escape(app_name)
    rule_line = f'yabai -m rule --add app="^{escaped_name}$" manage=off'

    config_path = pathlib.Path.home() / ".config" / "yabai" / "yabairc"
    if not config_path.exists():
        print(f"未找到配置文件: {config_path}", file=sys.stderr)
        return 1

    lines = config_path.read_text(encoding="utf-8").splitlines()

    if rule_line in lines:
        already_exists = True
    else:
        already_exists = False
        if START_MARKER in lines and END_MARKER in lines:
            end_idx = lines.index(END_MARKER)
            lines.insert(end_idx, rule_line)
        else:
            if lines and lines[-1] != "":
                lines.append("")
            lines.extend([START_MARKER, rule_line, END_MARKER])

        config_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    if not window.get("is-floating", False):
        subprocess.run(["yabai", "-m", "window", "--toggle", "float"], check=False)

    run(["yabai", "--restart-service"])

    if already_exists:
        print(f"app 已存在 always float 规则: {app_name}")
    else:
        print(f"已添加 always float 规则: {app_name}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
