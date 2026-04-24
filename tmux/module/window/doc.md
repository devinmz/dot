# Window Manage

本目录为 `tmux/module/window` 的独立实现，负责 window 的创建、重命名、删除、切换和顺序调整。

## 功能

### 创建 window

- `prefix c`：提示输入 window 名，并创建到当前 window 后面。
- `prefix s`：提示输入 window 名，并创建到 window 列表最后。
- 起始目录使用当前 pane 的工作目录 `pane_current_path`。

实现：`create.sh` -> `helper.py create <mode> <label> <path>`

### 重命名 window

- `prefix r`：弹出输入框，默认填入当前 window 名称，确认后重命名当前 window。

实现：`helper.py rename <label>`

### 删除 window

- `prefix k`：弹出输入框，支持输入 window 索引或完整名称。
- 若留空，则删除当前 window。
- 若删除的是当前 window：
  - 还有其他 window 时，先切到相邻 window 再删除；
  - 仅剩一个 window 时，直接执行 `kill-window`。

实现：`kill.sh` -> `helper.py kill [target]`

### 切换与调整顺序

- `prefix 1..9`：直接切到对应 window。
- `Ctrl+w` 然后 `1..9`：进入 `window-switch` key table 后切换 window。
- `Ctrl+w` 然后 `Left/Right`：在 `window-switch` key table 中左右移动当前 window，并保持在该模式中，可连续多次按方向键。

实现：

- `switch_index.sh` -> `helper.py switch <N>`
- `switch_move.sh` -> `helper.py move <left|right>`

## 默认绑定

| 按键 | 作用 |
|------|------|
| `prefix c` | 创建到当前 window 后面 |
| `prefix s` | 创建到最后 |
| `prefix r` | 重命名当前 window |
| `prefix k` | 输入要删除的 window；留空删除当前 window |
| `prefix 1..9` | 直接切换到对应 window |
| `Ctrl+w`, 然后 `1..9` | 进入 `window-switch` 模式并切换 window |
| `Ctrl+w`, 然后 `Left/Right` | 在 `window-switch` 模式中连续左移/右移当前 window |
