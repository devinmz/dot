source "${${(%):-%x}:A:h}/util/index.zsh"
source "$_Z/yqg/index.zsh"
source "$_Z/me/index.zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.npm-global/bin:$PATH"
