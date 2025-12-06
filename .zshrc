# .zshrc - Zsh interactive shell configuration
# Runs for each new interactive terminal

# Minimal setup for AI agents
if [[ -n "$AI_AGENT" ]]; then
    PS1='$ '
    return
fi

# ---------------------
# Zsh Options
# ---------------------
setopt HIST_IGNORE_DUPS       # Don't record duplicate commands
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt SHARE_HISTORY          # Share history between sessions
setopt APPEND_HISTORY         # Append to history file
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ---------------------
# Completions
# ---------------------
autoload -Uz compinit && compinit

# NVM bash completion (works in zsh)
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ---------------------
# Antidote Plugin Manager
# ---------------------
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# ---------------------
# Starship Prompt
# ---------------------
eval "$(starship init zsh)"

# ---------------------
# Zsh-specific aliases
# ---------------------
alias resource="source ~/.zshrc && source ~/.zprofile"
