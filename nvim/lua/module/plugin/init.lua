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

local function append_specs(specs, module_name)
    for _, spec in ipairs(require(module_name)) do
        table.insert(specs, spec)
    end
end

local specs = {}
append_specs(specs, "module.plugin.specs.colorscheme")
append_specs(specs, "module.plugin.specs.editor")
append_specs(specs, "module.plugin.specs.lsp")
append_specs(specs, "module.plugin.specs.tools")
append_specs(specs, "module.plugin.specs.completion")

require("lazy").setup({
    spec = specs,
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
