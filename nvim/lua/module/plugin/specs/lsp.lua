local servers = {
    "lua_ls", "ts_ls", "gopls", "rust_analyzer",
    "pyright", "volar", "yamlls", "taplo", "marksman",
}

local function setup_lsp_config()
    -- 全局 LSP 键位（保留 ; 作为 leader），避免在未挂载 LSP 时退化为普通按键
    vim.keymap.set("n", "<leader>l", "<Nop>", { noremap = true, silent = true, desc = "LSP Prefix" })

    local function with_lsp(action)
        return function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
                vim.notify("当前 buffer 未挂载 LSP", vim.log.levels.WARN)
                return
            end
            action()
        end
    end

    vim.keymap.set("n", "<leader>lh", with_lsp(vim.lsp.buf.hover), { noremap = true, silent = true, desc = "LSP Hover" })
    vim.keymap.set("n", "<leader>ld", with_lsp(vim.lsp.buf.definition), { noremap = true, silent = true, desc = "LSP Definition" })
    vim.keymap.set("n", "<leader>lr", with_lsp(vim.lsp.buf.references), { noremap = true, silent = true, desc = "LSP References" })
    vim.keymap.set("n", "<leader>ln", with_lsp(vim.lsp.buf.rename), { noremap = true, silent = true, desc = "LSP Rename" })
    vim.keymap.set("n", "<leader>la", with_lsp(vim.lsp.buf.code_action), { noremap = true, silent = true, desc = "LSP Code Action" })
    vim.keymap.set("n", "<leader>lf", with_lsp(vim.lsp.buf.format), { noremap = true, silent = true, desc = "LSP Format" })
    vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "LSP Diagnostic Float" })

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

    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
    })

    for _, server in ipairs(servers) do
        vim.lsp.config(server, {
            on_attach = on_attach,
        })
    end

    vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        settings = {
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
    })
end

return {
    -- LSP 管理器
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },

    -- LSP 配置
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = setup_lsp_config,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        dependencies = { "mason.nvim", "nvim-lspconfig" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_enable = true,
            })
        end,
    },
}
