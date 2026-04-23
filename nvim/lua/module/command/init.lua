-- 用户自定义命令

-- ============================================================================
-- ReloadNvim: 重新加载配置
--
-- 清空用户自定义模块的 package.loaded 缓存，然后重新 source $MYVIMRC。
-- 注意：并不会真正重启 nvim 进程，只是重新执行一次配置入口。
-- 第三方插件（lazy.nvim 等）的 runtime 状态保持不变，仅用户模块重新加载。
-- ============================================================================
vim.api.nvim_create_user_command("ReloadNvim", function()
    for name, _ in pairs(package.loaded) do
        if name == "main" or name:match("^module") then
            package.loaded[name] = nil
        end
    end

    local config = vim.env.MYVIMRC
    if not config or config == "" then
        config = vim.fn.stdpath("config") .. "/init.lua"
    end

    local ok, err = pcall(dofile, config)
    if ok then
        vim.notify("Nvim config reloaded: " .. config, vim.log.levels.INFO)
    else
        vim.notify("Reload failed: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "Reload Neovim user config (main/module.*)" })
