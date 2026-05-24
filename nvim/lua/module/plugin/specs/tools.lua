return {
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

    -- Debugprint
    {
        "andrewferrier/debugprint.nvim",
        version = "*",
        lazy = false,
        dependencies = { "folke/snacks.nvim" },
        opts = {
            picker = "snacks.picker",
            filetypes = {
                ["javascript"] = {
                    left = 'console.log("',
                    right = '")',
                    mid_var = '", ',
                    right_var = ")",
                },
                ["javascriptreact"] = {
                    left = 'console.log("',
                    right = '")',
                    mid_var = '", ',
                    right_var = ")",
                },
                ["typescript"] = {
                    left = 'console.log("',
                    right = '")',
                    mid_var = '", ',
                    right_var = ")",
                },
                ["typescriptreact"] = {
                    left = 'console.log("',
                    right = '")',
                    mid_var = '", ',
                    right_var = ")",
                },
            },
            keymaps = {
                normal = {
                    plain_below = false,
                    plain_above = false,
                    surround_plain = false,
                    variable_below = "<leader>dv",
                    variable_above = "<leader>dV",
                    textobj_below = "<leader>do",
                    textobj_above = "<leader>dO",
                    textobj_surround = "<leader>dso",
                    variable_below_alwaysprompt = false,
                    variable_above_alwaysprompt = false,
                    delete_debug_prints = "<leader>dd",
                    toggle_comment_debug_prints = "<leader>dc",
                },
                insert = {
                    plain = false,
                    variable = "<C-g>v",
                },
            },
        },
    },
}
