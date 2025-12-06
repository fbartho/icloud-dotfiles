# .profile - Bash login shell configuration
# Sources shared config, then adds bash-specific setup

# Silence macOS bash deprecation warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# Load shared configuration (PATH, env vars, nvm, etc.)
. "$HOME/.shell-common.sh"

# =====================
# Bash-specific settings
# =====================

# Stickier history
shopt -s histappend

# Skip interactive setup for AI agents
if [ -n "$AI_AGENT" ]; then
    export PS1='$ '
    return 0 2>/dev/null || exit 0
fi

# Git completion (tab completion for git commands)
if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
    . /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
elif [ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash ]; then
    . /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
else
    echo "No git-completion.bash found"
fi

# Bash completion (requires `brew install bash-completion`)
BREW_PREFIX="${BREW_PREFIX:-$(brew --prefix)}"
if [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
    . "$BREW_PREFIX/etc/bash_completion"
fi

# NVM bash completion
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Yarn tab-completion
[ -f ~/.config/yarn/global/node_modules/tabtab/.completions/yarn.bash ] && . ~/.config/yarn/global/node_modules/tabtab/.completions/yarn.bash

# Starship prompt
eval "$(starship init bash)"
