return {
    {
        "Shatur/neovim-ayu",
        name = "ayu",
        lazy = false,
        priority = 1000,
        config = function()
            require("ayu").setup({
                mirage = true,
                terminal = true,
            })
            vim.cmd("colorscheme ayu")

            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
            vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
            vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
        end
    },
}
