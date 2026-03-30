# Dotfiles zsh 根目录（util/ 的上一级）；须最先被 .zshrc source
function _Z {
  print -r -- "${${(%):-%x}:A:h:h}"
}

typeset -gx _Z="$(_Z)"

unset -f _Z
