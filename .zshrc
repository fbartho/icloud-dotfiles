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

# Keep `claude --init` invocations out of the history file — they often carry
# long personal prompts. The bare start-day form is the one allowed exception.
# Return 2 = kept in this session's memory (up-arrow works), never written to disk.
_hist_ban_claude_init() {
    local line=${1%$'\n'}
    if [[ $line == 'claude --init'* && $line != 'claude --init "/start-day"' ]]; then
        return 2
    fi
    return 0
}
autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _hist_ban_claude_init

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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/fbarthelemy/Code/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/fbarthelemy/Code/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/fbarthelemy/Code/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/fbarthelemy/Code/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/fbarthelemy/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/fbarthelemy/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/fbarthelemy/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/fbarthelemy/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
