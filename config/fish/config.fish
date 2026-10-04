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

# Rust, sccache, and JavaScript caches: a translation of .zshenv, ahead of the agent early return
set -gx CARGO_HOME "$HOME/.cargo"
set -gx RUSTUP_HOME "$HOME/.rustup"
set -gx SCCACHE_DIR "$HOME/.cache/sccache"
set -gx SCCACHE_CACHE_SIZE 20G
set -gx SCCACHE_IDLE_TIMEOUT 0
# An absolute path, since Homebrew is not yet on PATH here. A RUSTC_WRAPPER the caller sets, even to empty, is kept.
if not set -q RUSTC_WRAPPER
    for _sccache in "$CARGO_HOME/bin/sccache" /opt/homebrew/bin/sccache /usr/local/bin/sccache (command -s sccache)
        if test -x "$_sccache"
            set -gx RUSTC_WRAPPER "$_sccache"
            break
        end
    end
    set -e _sccache
end
set -gx npm_config_cache "$HOME/.cache/js/npm"
set -gx BUN_INSTALL_CACHE_DIR "$HOME/.cache/js/bun"
set -gx pnpm_config_store_dir "$HOME/.cache/js/pnpm/store"
set -gx pnpm_config_cache_dir "$HOME/.cache/js/pnpm/cache"

# Minimal setup for AI agents
if set -q AI_AGENT
    # Use node silently
    nvm use default --silent 2>/dev/null
    command -q corepack; and command corepack enable &>/dev/null
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
fish_add_path "$CARGO_HOME/bin"

# Espressif Xtensa Rust toolchain (espup): on-demand; the export file is sh syntax, so evaluate it in sh
set -gx ESPUP_EXPORT_FILE "$HOME/.config/espup/export-esp.sh"
function esp-env
    set -gx LIBCLANG_PATH (sh -c ". $ESPUP_EXPORT_FILE; printf %s \"\$LIBCLANG_PATH\"")
    fish_add_path (sh -c ". $ESPUP_EXPORT_FILE; printf %s \"\$PATH\"" | tr ':' '\n' | grep '/.rustup/toolchains/esp/')
end

# PATH additions
fish_add_path "$HOME/.ebrain-vault/.scripts/bin"
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

# Wrap nvm to enable corepack after node is activated
functions -q nvm; and functions -c nvm _nvm_original
function nvm --wraps=_nvm_original
    _nvm_original $argv
    set -l ret $status
    # Enable corepack after nvm changes node version
    command -q corepack; and command corepack enable &>/dev/null
    return $ret
end

# Starship prompt
starship init fish | source

# Load aliases
source ~/.aliases.fish

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/fbarthelemy/Code/miniconda3/bin/conda
    eval /Users/fbarthelemy/Code/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/Users/fbarthelemy/Code/miniconda3/etc/fish/conf.d/conda.fish"
        . "/Users/fbarthelemy/Code/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/Users/fbarthelemy/Code/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

