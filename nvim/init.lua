-- Neovim 内部使用的编码格式，通常设置为 utf-8。
vim.o.encoding = "UTF-8"
-- 文件保存时使用的编码格式，也建议设置为 utf-8
vim.o.fileencoding = "UTF-8"
-- tab显示为4个空格长度
vim.o.tabstop = 4
-- 空格替代
vim.bo.expandtab = true
-- 当按下 Tab 键时，Neovim 会插入空格（而不是 Tab 字符），直到达到 softtabstop 的宽度。
vim.o.softtabstop = 4
-- 当使用 >> 或 <<（缩进或取消缩进）时，shiftround 会将缩进对齐到最近的 shiftwidth 的倍数。
vim.o.shiftround = true
-- >> << 时移动长度
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4
-- jkhl 移动时光标周围保留8行
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
-- 显示行号
vim.wo.number = true
-- 使用相对行号
vim.wo.relativenumber = true
-- 高亮所在行列
-- vim.wo.cursorline = true
-- vim.wo.cursorcolumn = true
-- 显示左侧图标指示列，比如断点或者git标志
vim.wo.signcolumn = "yes"
-- 右侧参考线
-- vim.wo.colorcolumn = "160"
-- 新行对齐当前行
vim.o.autoindent = true
vim.o.smartindent = true
-- 搜索大小写不敏感，除非包含大写
vim.o.ignorecase = true
vim.o.smartcase = true
-- 搜索不要高亮
vim.o.hlsearch = false
vim.o.incsearch = true
-- 命令模式行高
vim.o.cmdheight = 1
-- 自动加载外部修改
vim.o.autoread = true
-- 禁止折行
vim.wo.wrap = false
-- 光标在行首尾时<Left><Right>可以跳到下一行
vim.o.whichwrap = "<,>,[,]"
-- 允许隐藏被修改过的buffer
vim.o.hidden = true
-- 鼠标支持
vim.o.mouse = "a"
-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
-- smaller updatetime
vim.o.updatetime = 300
-- 控制按键映射的超时时间
vim.o.timeoutlen = 500
-- 控制分割窗口时新窗口的位置
vim.o.splitbelow = true
vim.o.splitright = true
-- 自动补全不自动选中，即使只有一个补全选项，也显示补全菜单
vim.g.completeopt = "menu,menuone,noselect,noinsert"
-- 样式
vim.o.background = "dark"
vim.o.termguicolors = true
-- 不可见字符的显示，这里只把空格显示为一个点
vim.o.list = false
vim.o.listchars = "space:·,tab:>-"

-- 命令提示菜单，pum=popup
vim.o.wildmenu = true

vim.o.shortmess = vim.o.shortmess .. "c"
-- 补全显示10行
vim.o.pumheight = 10
-- 将 Neovim 的剪贴板与系统剪贴板同步
vim.o.clipboard = "unnamedplus"

vim.g.mapleader = ";"

require('main')