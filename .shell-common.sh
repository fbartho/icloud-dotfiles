# .shell-common.sh - Shared shell configuration (POSIX-compatible)
# Sourced by .profile (bash) and .zprofile (zsh)
# Fish and nushell have their own native translations

# XDG Base Directory (makes nushell use ~/.config/nushell/)
export XDG_CONFIG_HOME="$HOME/.config"

# Detect AI agents and set unified variable
# Known: CLAUDECODE, GEMINI_CLI, CURSOR_TRACE_ID, AIDER
if [ -n "$CLAUDECODE" ] || [ -n "$GEMINI_CLI" ] || [ -n "$CURSOR_TRACE_ID" ] || [ -n "$AIDER" ]; then
    export AI_AGENT=1
fi

# Random shell prompt emoji - affects sh-compatible shells (but not fish, nu)
SHELL_PROMPTS=(
    '$' '☀' '⭐'
    '🍀' '🌎' '⛄' '🌊' '💩' '🔥'
    '🍺' '🥟' '🥘' '🍛' '🍣' '🍹'
    '🚀' '🌙' '✨' '🪐' '☄️' '💫'
    '🌸' '🌵' '🍄' '🌴' '🦋' '🌈'
    '🦊' '🐙' '🦉' '🐢' '🐳' '🦎'
    '⚡' '💎' '🎯' '🔮' '🎲' '⚓'
    '👾' '🤖' '👻' '🎃' '🍕' '🌮'
)
export SHELL_EMOJI="${SHELL_PROMPTS[$((RANDOM % ${#SHELL_PROMPTS[@]}))]}"

# Homebrew setup (Apple Silicon vs Intel)
CPU=$(uname -p)
if [ "$CPU" = "arm" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    alias oldbrew="/usr/local/bin/brew"
else
    export PATH="/usr/local/bin:$PATH"
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Core environment variables
export EDITOR=emacs
export CODE_DIR="$HOME/Code"
export ICLOUD_DRIVE="$HOME/.icloud-drive"
export GPG_TTY=$(tty)

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
unset npm_config_prefix
unset PREFIX
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# rbenv (Ruby)
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

# pyenv (Python)
if command -v pyenv >/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Rust/Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# PATH additions
PATH="$HOME/.bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$CODE_DIR/go_use/bin:$PATH"
PATH="/usr/local/sbin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
if [ -d "$ANDROID_HOME" ]; then
    PATH="$PATH:$ANDROID_HOME/emulator"
    PATH="$PATH:$ANDROID_HOME/tools"
    PATH="$PATH:$ANDROID_HOME/tools/bin"
    PATH="$PATH:$ANDROID_HOME/platform-tools"
fi

# OpenSSL
PATH="/usr/local/opt/openssl/bin:$PATH"
export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/opt/openssl/lib/"

# GSL
PATH="/usr/local/opt/gsl@1/bin:$PATH"

export PATH

# Source private environment variables (encrypted disk image)
[ -f "/Volumes/secure-dotfiles/.env" ] && . "/Volumes/secure-dotfiles/.env"

# GPG agent
if [ -S ~/.gnupg/S.gpg-agent ]; then
    [ -z "$AI_AGENT" ] && echo "[gpg-agent]: status is good."
else
    eval $(gpg-agent --daemon 2>/dev/null)
fi

# Increase file descriptor limit
ulimit -n 10000

# Use default node version
if [ -n "$AI_AGENT" ]; then
    nvm use default --silent 2>/dev/null
else
    nvm use default
fi

# Activate yarn berry
corepack enable 2>/dev/null

# Load aliases
[ -f "$HOME/.aliases.sh" ] && . "$HOME/.aliases.sh"

# go_use utility
if command -v go_use_aliases >/dev/null 2>&1; then
    . "$(which go_use_aliases)"
    . "$(which go_use_fixup_env)"
fi

# conda python ML Model framework (lazy-loaded)
# Defines a stub function that bootstraps conda on first use
conda() {
    unset -f conda
    source "$HOME/Code/miniconda3/bin/activate"
    conda init --all >/dev/null 2>&1
    conda "$@"
}
