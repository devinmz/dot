---
id: defer-lua-module-setup
trigger: when configuring Neovim plugins that can block startup, especially LSP and treesitter initialization
confidence: 0.65
domain: code-style
source: session-observation
scope: project
project_id: 48816c564ec4
project_name: dotfiles
---

# Defer Heavy Lua Module Setup with vim.defer_fn()

## Action
Wrap module-intensive plugin configuration (LSP server setup, treesitter initialization) in `vim.defer_fn()` to prevent blocking Neovim startup, then use `pcall()` for optional operations that may fail gracefully.

## Evidence
- Observed 2+ times in session ff5c6adf (nvim/lua/module/plugin/init.lua edits)
- Pattern: Moving mason-lspconfig setup from eager config function into deferred callback
- Pattern: Using pcall() to safely attempt optional extensions like telescope.load_extension and builtin.treesitter
- Last observed: 2026-03-31 (event 4, 6)

## Details
When LSP or treesitter configuration is placed directly in the lazy.nvim config block, it runs synchronously during startup. Deferring this work:
- Keeps vim startup fast and responsive
- Allows parsers/servers to initialize in background
- Pairs naturally with pcall() for fallback behavior when modules aren't ready

