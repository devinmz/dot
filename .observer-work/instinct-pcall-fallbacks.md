---
id: pcall-with-vim-notify-fallback
trigger: when loading optional Neovim plugins or features that may not be installed
confidence: 0.70
domain: code-style
source: session-observation
scope: project
project_id: 48816c564ec4
project_name: dotfiles
---

# Wrap Optional Plugin Operations in pcall()

## Action
Use `pcall()` to safely attempt optional plugin operations (extension loading, builtin functions) and implement graceful fallbacks instead of letting errors propagate.

## Evidence
- Observed 3+ times in session ff5c6adf
- Pattern: `pcall(telescope.load_extension, "fzf")` (event 6)
- Pattern: `local ok = pcall(builtin.treesitter)` with fallback to current_buffer_fuzzy_find (event 6)
- Pattern: Consistent use across telescope and treesitter operations
- Last observed: 2026-03-31 (event 6)

## Details
When optional plugins or features may not be available:
- Wrap in pcall() to prevent startup errors
- Use return value to choose fallback behavior
- Keep silent failures transparent (avoid vim.notify() spam for expected graceful degradation)
- Pairs well with deferred initialization to handle async loading states

