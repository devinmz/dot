---
id: local-require-wrapper-pattern
trigger: when wrapping require() calls in Lua plugin configuration files
confidence: 0.60
domain: code-style
source: session-observation
scope: project
project_id: 48816c564ec4
project_name: dotfiles
---

# Wrap require() Results in Local Variables

## Action
Assign require() calls to local variables at the top of plugin config functions instead of calling them inline, improving readability and following idiomatic Lua structure.

## Evidence
- Observed 2+ times in session ff5c6adf
- Pattern: `local lspconfig = require("lspconfig")` followed by `local mason_lspconfig = require("mason-lspconfig")`
- Pattern: `local telescope = require("telescope")` and `local actions = require("telescope.actions")`
- Last observed: 2026-03-31 (event 2, 6)

## Details
This pattern:
- Makes dependencies explicit at function entry
- Enables IDE autocomplete and refactoring
- Mirrors patterns seen in your nvim/lazy-lock.json dependencies
- Works well with deferred initialization (wrap the locals inside vim.defer_fn callback)

