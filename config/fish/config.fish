# config.fish - Fish shell configuration
# Fish-native translation of .shell-common.sh

# XDG Base Directory (makes nushell use ~/.config/nushell/)
set -gx XDG_CONFIG_HOME "$HOME/.config"

# Detect AI agents and set unified variable
if set -q CLAUDECODE; or set -q GEMINI_CLI; or set -q CURSOR_TRACE_ID; or set -q AIDER
    set -gx AI_AGENT 1
end

# Random shell prompt emoji (used by starship)
set -l _shell_prompts \
    '$' '☀' '⭐' \
    '🍀' '🌎' '⛄' '🌊' '💩' '🔥' \
    '🍺' '🥟' '🥘' '🍛' '🍣' '🍹' \
    '🚀' '🌙' '✨' '🪐' '☄️' '💫' \
    '🌸' '🌵' '🍄' '🌴' '🦋' '🌈' \
    '🦊' '🐙' '🦉' '🐢' '🐳' '🦎' \
    '⚡' '💎' '🎯' '🔮' '🎲' '⚓' \
    '👾' '🤖' '👻' '🎃' '🍕' '🌮'
set -gx SHELL_EMOJI $_shell_prompts[(random 1 (count $_shell_prompts))]

# Minimal setup for AI agents
if set -q AI_AGENT
    # Use node silently
    nvm use default --silent 2>/dev/null
    corepack enable 2>/dev/null
    # Simple prompt
    function fish_prompt
        echo '$ '
    end
    return
end

# Homebrew setup (Apple Silicon vs Intel)
if test (uname -p) = "arm"
    eval (/opt/homebrew/bin/brew shellenv)
    alias oldbrew="/usr/local/bin/brew"
else
    eval (/usr/local/bin/brew shellenv)
end

# Core environment variables
set -gx EDITOR emacs
set -gx CODE_DIR "$HOME/Code"
set -gx ICLOUD_DRIVE "$HOME/.icloud-drive"
set -gx GPG_TTY (tty)

# NVM - using nvm.fish (fish-native implementation)
# Install: fisher install jorgebucaran/nvm.fish
set -gx NVM_DIR "$HOME/.nvm"
set -gx nvm_data "$NVM_DIR/versions/node"  # Use existing bash nvm versions

# rbenv (Ruby)
if command -v rbenv >/dev/null 2>&1
    status --is-interactive; and rbenv init - fish | source
end

# pyenv (Python)
if command -v pyenv >/dev/null 2>&1
    set -gx PYENV_ROOT "$HOME/.pyenv"
    fish_add_path "$PYENV_ROOT/bin"
    pyenv init - fish | source
end

# Rust/Cargo
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
else if test -d "$HOME/.cargo/bin"
    fish_add_path "$HOME/.cargo/bin"
end

# PATH additions
fish_add_path "$HOME/.bin"
fish_add_path "$HOME/.local/bin"
fish_add_path "$CODE_DIR/go_use/bin"
fish_add_path "/usr/local/sbin"

# Android SDK
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
if test -d "$ANDROID_HOME"
    fish_add_path "$ANDROID_HOME/emulator"
    fish_add_path "$ANDROID_HOME/tools"
    fish_add_path "$ANDROID_HOME/tools/bin"
    fish_add_path "$ANDROID_HOME/platform-tools"
end

# OpenSSL
fish_add_path "/usr/local/opt/openssl/bin"
set -gx LIBRARY_PATH "$LIBRARY_PATH:/usr/local/opt/openssl/lib/"

# GSL
fish_add_path "/usr/local/opt/gsl@1/bin"

# Source private environment variables (encrypted disk image)
if test -f "/Volumes/secure-dotfiles/.env.fish"
    source "/Volumes/secure-dotfiles/.env.fish"
end

# GPG agent
if test -S ~/.gnupg/S.gpg-agent
    echo "[gpg-agent]: status is good."
else
    eval (gpg-agent --daemon 2>/dev/null)
end

# Increase file descriptor limit
ulimit -n 10000

# Use default node version (nvm.fish handles this automatically)

# Activate yarn berry
corepack enable 2>/dev/null

# Starship prompt
starship init fish | source

# Load aliases
source ~/.aliases.fish
