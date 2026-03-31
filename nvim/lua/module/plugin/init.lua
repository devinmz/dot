local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        {
            "catppuccin/nvim",
            name = "catppuccin",
            opts = {
                transparent_background = true
            },
            integrations = {
                treesitter = true,
                native_lsp = {
                  enabled = true,
                },
            },
            config = function (_, opts)
                require("catppuccin").setup(opts)
                vim.cmd("colorscheme catppuccin-mocha")

                vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
                vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
                vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
                vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
            end
        },

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

        -- LSP 管理器
        {
            "williamboman/mason.nvim",
            lazy = false,
            config = function()
                require("mason").setup()
            end,
        },

        {
            "williamboman/mason-lspconfig.nvim",
            lazy = false,
            dependencies = { "mason.nvim" },
            config = function()
                require("mason-lspconfig").setup({
                    ensure_installed = {
                        "lua_ls", "ts_ls", "gopls", "rust_analyzer",
                        "pyright", "volar", "yamlls", "taplo", "marksman",
                    },
                    automatic_installation = true,
                })
            end,
        },

        -- LSP 配置
        {
            "neovim/nvim-lspconfig",
            lazy = false,
            dependencies = { "mason-lspconfig.nvim" },
            config = function()
                local lspconfig = require("lspconfig")

                -- 通用 on_attach
                local on_attach = function(client, bufnr)
                    local opts = { noremap = true, silent = true, buffer = bufnr }

                    -- LSP 操作键位映射（<leader>l 前缀）
                    vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, opts)
                    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, opts)
                    vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, opts)

                    -- 诊断导航
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                end

                -- 诊断配置
                vim.diagnostic.config({
                    virtual_text = true,
                    signs = true,
                    underline = true,
                    update_in_insert = false,
                })

                -- 延迟配置 LSP 服务器
                vim.defer_fn(function()
                    local mason_lspconfig = require("mason-lspconfig")

                    -- 自动配置所有由 mason-lspconfig 安装的服务器
                    mason_lspconfig.setup_handlers({
                        function(server_name)
                            local config = {
                                on_attach = on_attach,
                            }

                            -- Lua LSP 特殊配置
                            if server_name == "lua_ls" then
                                config.settings = {
                                    Lua = {
                                        diagnostics = {
                                            globals = { "vim" }
                                        },
                                        workspace = {
                                            library = vim.api.nvim_get_runtime_file("", true),
                                            checkThirdParty = false
                                        },
                                        telemetry = { enable = false }
                                    }
                                }
                            end

                            lspconfig[server_name].setup(config)
                        end
                    })
                end, 100)
            end,
        },

        -- Claude Code 集成
        {
            "folke/snacks.nvim",
            lazy = false,
            config = function()
                require("snacks").setup()
            end,
        },

        {
            "coder/claudecode.nvim",
            lazy = false,
            dependencies = { "folke/snacks.nvim" },
            config = function()
                require("claudecode").setup()

                -- 创建自定义命令：Send 后直接聚焦 CC 窗口
                vim.api.nvim_create_user_command("ClaudeCodeSendFocus", function()
                    vim.cmd("ClaudeCodeSend")
                    vim.cmd("ClaudeCodeFocus")
                end, { range = true })
            end,
            keys = {
                { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
                { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
                { "<leader>cs", ":<C-u>ClaudeCodeSendFocus<cr>", mode = "v", desc = "Send to Claude & Focus" },
                { "<leader>cS", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
                { "<C-[>", "<cmd>wincmd p<cr>", mode = "t", desc = "Switch to Code Window" },
            },
        },

        -- 缩进线
        {
            "lukas-reineke/indent-blankline.nvim",
            lazy = false,
            main = "ibl",
            config = function()
                require("ibl").setup({
                    indent = {
                        char = "│",
                        tab_char = "│",
                    },
                    scope = {
                        enabled = true,
                        char = "│",
                        show_start = true,
                        show_end = true,
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

        -- 补全引擎
        {
            "hrsh7th/nvim-cmp",
            lazy = false,
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "L3MON4D3/LuaSnip",
                "saadparwaiz1/cmp_luasnip",
            },
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ["<C-n>"] = cmp.mapping.select_next_item(),
                        ["<C-e>"] = cmp.mapping.select_prev_item(),
                        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                        ["<C-Space>"] = cmp.mapping.complete(),
                        ["<Esc>"] = cmp.mapping.abort(),
                    }),
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                    }, {
                        { name = "buffer" },
                        { name = "path" },
                    }),
                })
            end,
        },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
