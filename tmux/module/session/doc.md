# Session Manage

本目录为 **独立实现**，**不依赖** `tmux/scripts/`（后者是另一套路由与脚本，请勿混改）。
主配置建议通过 `~/.config/tmux/module/session/init.conf` 引入本模块绑定。

## 背景

创建、删除、detach session，前提是当前已经在 tmux 进程中。

## 功能

### 创建 session

- 创建时可输入 session **标签名**（`command-prompt`）；留空则只做 `1-xxx` 编号命名。
- 创建完成后**切换到新 session**。
- 起始目录使用**当前 pane 的工作目录**（`pane_current_path`）。
- 提供两种创建方式：
  - **prefix C**：新 session 插入到**当前 session 后面**
  - **prefix S**：新 session 添加到 session 列表的**最后一个**位置

### 重命名 session

- **prefix R**：弹出输入框，默认填入当前 session 名称，确认后执行 `rename-session` 更新当前 session 名称。

实现：`create.sh <mode>` → 同目录 **`helper.py`**（`insert-right` / `ensure` / `rename`）。

### 删除 session

- **prefix K**：弹出输入框，支持输入排序索引、完整 session 名或 label。
- 若**留空**，则删除当前 session。
- 若删除的是当前 session：
  - 仅有一个 session 时，直接 kill；
  - 当前为排序列表中的**第一个**时，先切换到**下一个**（索引 +1）再 kill；
  - 其余情况先切换到**上一个**（索引 -1）再 kill。
- 删除后会对剩余 session 重新编号，保持排序前缀连续。

实现：**`helper.py`** 子命令 **`kill`**，由 **`kill.sh`** 调用。

### detach session

实现：配置里直接使用 **`detach-client`**。

### 切换 session

- **按索引**：先按 **`Ctrl+l`** 进入 `session-switch` key table，再通过 **`helper.py switch <N>`** 按排序后的第 N 个 session 切换（从 **1** 开始）；`switch_index.sh` 是其 shell 包装。
- **交互列表**：**`switch_menu.sh`** → `choose-session -NZ`。

### 调整 session 顺序

- **prefix + Left**：将当前 session 在排序列表中左移一位。
- **prefix + Right**：将当前 session 在排序列表中右移一位。
- **Ctrl+l**, 然后 **Left/Right**：进入 `session-switch` key table 后调整顺序；按一次 **Ctrl+l** 后可连续多次按 **Left/Right**。

实现：直接调用 **`helper.py move left|right`**，并重新按当前位置刷新编号前缀。

### 管理能力

模块版 `helper.py` 现已提供与 `scripts/session_manager.py` 对齐的主要 manage 子命令：

- `switch <N>`（1-based）
- `rename <label>`
- `move <left|right>`
- `insert-right <anchor_id> <moving_id>`
- `ensure`
- `created`
- `kill [target]`
- `move-window-to <N>`（1-based）

另外 `init.conf` 中注册了模块版 `session-created` hook，会调用 `created.sh`，在原生新建 session 后自动执行 `created -> ensure`，保持编号连续。

## 实现文件

| 文件 | 说明 |
|------|------|
| **`helper.py`** | 模块版 session manager：切换、排序、插入、重命名、关闭、移动 window |
| `create.sh` | 新建 session；锁文件 **`/tmp/tmux-module-new-session.lock`**（与 `scripts/` 下的 `new_session.sh` 所用锁分开） |
| `kill.sh` | `kill [target]` |
| `created.sh` | 模块版 `session-created` hook 入口 |
| `switch_menu.sh` | 交互选 session |
| `switch_index.sh` | 调用 `helper.py switch <N>` 的包装脚本 |

## 模块入口

在主配置中引入：

```tmux
source-file ~/.config/tmux/module/session/init.conf
```

## 默认绑定（见 `init.conf`，前缀 **Ctrl+y**）

| 按键 | 作用 |
|------|------|
| **prefix C** | 提示输入 Session 名，并创建到当前 session 后面 |
| **prefix S** | 提示输入 Session 名，并创建到 session 列表最后 |
| **prefix R** | 提示输入新名称，并重命名当前 session |
| **prefix K** | 输入要删除的 session；留空则删除当前 session |
| **prefix D** | detach |
| **prefix Left** | 当前 session 左移一位 |
| **prefix Right** | 当前 session 右移一位 |
| **Ctrl+l**, 然后 **1 … 8** | 进入 `session-switch` key table，并按排序后的 session 索引切换 |
| **Ctrl+l**, 然后 **Left/Right** | 在 `session-switch` key table 中连续左移/右移当前 session |

## 完整配置 `.tmux.conf`（前缀 **Ctrl+s**）

若另一份配置存在键位冲突（例如已占用 **Alt+s**），建议在那份配置里单独决定是否引入 `init.conf`，或在引入后做局部覆盖。**Alt+Shift+S**、**`scripts/new_session.sh`** 等仍为另一套实现，与本模块并行存在时可各自使用。

部署：将仓库 `tmux/` 链到 **`~/.config/tmux`**，并为 `module/session/*.sh` 赋予可执行权限。
