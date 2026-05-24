return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc",
                    "javascript", "typescript", "tsx",
                    "html", "css", "json", "yaml", "toml",
                    "bash", "markdown", "markdown_inline", "kdl",
                    "go", "rust", "python",
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- 文件浏览器
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            local api = require("nvim-tree.api")

            local function on_attach(bufnr)
                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                api.config.mappings.default_on_attach(bufnr)

                -- Colemak: 移除与导航键冲突的默认映射
                vim.keymap.del("n", "e", { buffer = bufnr })

                -- Colemak 导航 (与全局 keymap 一致: n=下, e=上, i=右/打开)
                vim.keymap.set("n", "n", "j", opts("Cursor Down"))
                vim.keymap.set("n", "e", "k", opts("Cursor Up"))
                vim.keymap.set("n", "i", "l", opts("Cursor Right"))

                -- 移除可能与自定义映射冲突的默认键
                pcall(vim.keymap.del, "n", "-", { buffer = bufnr })
                pcall(vim.keymap.del, "n", "t", { buffer = bufnr })

                -- 打开方式：- 水平分屏，= 垂直分屏，t 新 tab
                vim.keymap.set("n", "-", api.node.open.horizontal, opts("Open: Horizontal Split"))
                vim.keymap.set("n", "=", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
            end

            require("nvim-tree").setup({
                on_attach = on_attach,
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = false,
                },
            })

            vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
            vim.keymap.set("n", "<leader>ft", "<cmd>NvimTreeFocus<CR>", { desc = "Focus NvimTree" })
        end,
    },

    -- 文件重命名/移动时同步 LSP 导入与引用
    {
        "antosha417/nvim-lsp-file-operations",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-tree.lua",
        },
        config = function()
            require("lsp-file-operations").setup()
        end,
    },

    -- 模糊搜索
    {
        "nvim-telescope/telescope.nvim",
        branch = "master",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
        config = function()
            local actions = require("telescope.actions")
            local telescope = require("telescope")

            telescope.setup({
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
                defaults = {
                    layout_strategy = "bottom_pane",
                    layout_config = {
                        bottom_pane = {
                            height = 0.4,
                            preview_cutoff = 120,
                            prompt_position = "top",
                        },
                    },
                    sorting_strategy = "ascending",
                    mappings = {
                        i = {
                            -- Colemak 导航
                            ["<C-n>"] = actions.move_selection_next,
                            ["<C-e>"] = actions.move_selection_previous,
                            -- 单次 Esc 直接关闭
                            ["<Esc>"] = actions.close,
                        },
                    },
                },
            })

            pcall(telescope.load_extension, "fzf")

            -- 懒加载 builtin，避免 config 阶段触发模块循环
            local b = function(name) return function() require("telescope.builtin")[name]() end end
            local symbols = function()
                local builtin = require("telescope.builtin")

                -- 优先使用 LSP 符号（最准确）
                local clients = vim.lsp.get_active_clients({ bufnr = 0 })
                if #clients > 0 then
                    -- 配置选项显示符号的完整层级信息
                    builtin.lsp_document_symbols({
                        symbols = {
                            "Class", "Function", "Method", "Variable",
                            "Constructor", "Interface", "Module", "Struct",
                            "Enum", "Field", "Constant", "Property"
                        }
                    })
                    return
                end

                -- 降级到 treesitter
                local ok = pcall(builtin.treesitter)
                if not ok then
                    builtin.current_buffer_fuzzy_find()
                end
            end
            vim.keymap.set("n", "<leader>tf", b("find_files"),   { desc = "Telescope: Find Files" })
            vim.keymap.set("n", "<leader>tw", b("live_grep"),    { desc = "Telescope: Live Grep" })
            vim.keymap.set("n", "<leader>tb", b("buffers"),      { desc = "Telescope: Buffers" })
            vim.keymap.set("n", "<leader>tt", b("help_tags"),    { desc = "Telescope: Help Tags" })
            vim.keymap.set("n", "<leader>ts", symbols,           { desc = "Telescope: Symbols (LSP/treesitter/fallback)" })
        end,
    },

    -- 缩进线
    {
        "lukas-reineke/indent-blankline.nvim",
        lazy = false,
        main = "ibl",
        config = function()
            local highlights = {
                RainbowRed = "#E06C75",
                RainbowYellow = "#E5C07B",
                RainbowBlue = "#61AFEF",
                RainbowOrange = "#D19A66",
                RainbowGreen = "#98C379",
                RainbowViolet = "#C678DD",
                RainbowCyan = "#56B6C2",
                IblScope = "#ABB2BF",
            }
            for group, color in pairs(highlights) do
                vim.api.nvim_set_hl(0, group, { fg = color })
            end

            require("ibl").setup({
                indent = {
                    char = "│",
                    tab_char = "│",
                    highlight = {
                        "RainbowRed",
                        "RainbowYellow",
                        "RainbowBlue",
                        "RainbowOrange",
                        "RainbowGreen",
                        "RainbowViolet",
                        "RainbowCyan",
                    },
                },
                scope = {
                    enabled = true,
                    char = "│",
                    show_start = true,
                    show_end = true,
                    highlight = "IblScope",
                },
                exclude = {
                    filetypes = {
                        "help", "alpha", "dashboard",
                        "neo-tree", "Trouble", "lazy",
                        "mason", "notify"
                    },
                },
            })
        end,
    },
}
