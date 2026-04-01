-- Colemak 键盘布局映射

local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = true
    opts.silent = true
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================================
-- 核心导航键 (hjkl)
-- ============================================================================
-- h 保持不变（物理位置相同）
-- j (下) -> Colemak 物理位置输出 n
-- k (上) -> Colemak 物理位置输出 e
-- l (右) -> Colemak 物理位置输出 i

-- Normal, Visual, Operator-pending 模式
for _, mode in ipairs({ "n", "x", "o" }) do
    map(mode, "n", "j")  -- 物理 j 位置 -> 向下
    map(mode, "e", "k")  -- 物理 k 位置 -> 向上
    -- 保留 operator-pending 模式下的 `i` 文本对象（如 `diw`/`ciw`）
    if mode ~= "o" then
        map(mode, "i", "l")  -- 物理 l 位置 -> 向右
    end

    -- map(mode, "N", "J")  -- 合并行
    -- map(mode, "E", "K")  -- 查看文档
    -- map(mode, "I", "L")  -- 跳到屏幕底部
end

-- ============================================================================
-- 插入和撤销
-- ============================================================================
map("n", "u", "i")       -- 物理 i 位置 -> 插入
map("n", "U", "I")       -- 行首插入
map("n", "l", "u")       -- 撤销
map("n", "L", "U")       -- 整行撤销
map("n", "<C-l>", "<C-r>") -- Ctrl+l -> 重做

-- ============================================================================
-- 窗口导航 (空格 + hjkl)
-- ============================================================================
map("n", "<Space>h", "<C-w>h", { desc = "Window left" })
map("n", "<Space>n", "<C-w>j", { desc = "Window down" })
map("n", "<Space>e", "<C-w>k", { desc = "Window up" })
map("n", "<Space>i", "<C-w>l", { desc = "Window right" })

-- 窗口操作
map("n", "<Space>s", "<C-w>s", { desc = "Split horizontal" })
map("n", "<Space>v", "<C-w>v", { desc = "Split vertical" })
map("n", "<Space>c", "<C-w>c", { desc = "Close window" })
map("n", "<Space>o", "<C-w>o", { desc = "Close other windows" })
map("n", "<Space>=", "<C-w>=", { desc = "Equal window size" })
