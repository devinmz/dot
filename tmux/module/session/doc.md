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

实现：`create_session.sh` → 同目录 **`session_helper.py`**（`insert-right` / `ensure` / `rename`）。

### 删除 session

- 关闭当前 session；若还有其他 session，先切换到排序列表中的**上一个**（若在第一个则切到最后一个），再关闭当前会话。

实现：**`session_helper.py`** 子命令 **`kill-current`**，由 **`kill_session.sh`** 调用。

### detach session

实现：配置里直接使用 **`detach-client`**。

### 切换 session

- **按索引**：会话名形如 `1-work`，匹配前缀 **`switch_session_by_index.sh`**（本模块内脚本，逻辑为按名称 `N-` 匹配）。
- **交互列表**：**`switch_session_menu.sh`** → `choose-session -NZ`。

## 实现文件

| 文件 | 说明 |
|------|------|
| **`session_helper.py`** | 编号排序、插入、重命名、关闭并切到上一 session |
| `create_session.sh` | 新建 session；锁文件 **`/tmp/tmux-module-new-session.lock`**（与 `scripts/` 下的 `new_session.sh` 所用锁分开） |
| `kill_session.sh` | `kill-current` |
| `switch_session_menu.sh` | 交互选 session |
| `switch_session_by_index.sh` | 按 `N-` 前缀跳转 |

## 模块入口

在主配置中引入：

```tmux
source-file ~/.config/tmux/module/session/init.conf
```

## 默认绑定（见 `init.conf`，前缀 **Ctrl+y**）

| 按键 | 作用 |
|------|------|
| **prefix G** | 提示输入 Session 名并创建（当前目录） |
| **prefix X** | 确认后关闭当前 session，并切到「上一个」 |
| **prefix d** | detach |
| **Alt+s** | 交互选择 session |
| **Ctrl+1 … Ctrl+9** | 按 `N-` 前缀切换 |

## 完整配置 `.tmux.conf`（前缀 **Ctrl+s**）

若另一份配置存在键位冲突（例如已占用 **Alt+s**），建议在那份配置里单独决定是否引入 `init.conf`，或在引入后做局部覆盖。**Alt+Shift+S**、**`scripts/new_session.sh`** 等仍为另一套实现，与本模块并行存在时可各自使用。

部署：将仓库 `tmux/` 链到 **`~/.config/tmux`**，并为 `module/session/*.sh` 赋予可执行权限。
