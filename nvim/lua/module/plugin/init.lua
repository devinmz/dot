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
            'nvim-treesitter/nvim-treesitter',
            lazy = false,
            build = ':TSUpdate'
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
                require("nvim-tree").setup({
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
                -- 快捷键绑定
                vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
                vim.keymap.set("n", "<leader>ft", "<cmd>NvimTreeFocus<CR>", { desc = "Focus NvimTree" })
            end,
        }
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
